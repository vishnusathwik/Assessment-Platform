package com.assessment.platform.api;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Groups Landing AI OCR chunks into logical documents using spatial proximity.
 *
 * Usage:
 *
 * List<Map<String,Object>> docs =
 *      LogicalDocumentGrouper.group(jsonString);
 *
 * or
 *
 * List<Map<String,Object>> docs =
 *      LogicalDocumentGrouper.group(Path.of("landing.json"));
 */
public class LogicalDocumentGrouper {

    private static final ObjectMapper MAPPER = new ObjectMapper();

    private static final double DISTANCE_THRESHOLD = 0.28;
    private static final double ROW_THRESHOLD = 0.06;
    private static final double COLUMN_THRESHOLD = 0.06;
    private static final double SCORE_THRESHOLD = 5.0;

    record Box(double left,double top,double right,double bottom){
        double cx(){ return (left+right)/2.0; }
        double cy(){ return (top+bottom)/2.0; }
    }

    record Chunk(String id,String type,String markdown,Box box){}

    public static List<Map<String,Object>> group(Path jsonFile) throws Exception{
        List<Map<String,Object>> docs = group(Files.readString(jsonFile));
        System.out.println("Size of the list: "+docs.size());
        return docs;
    }

    public static List<Map<String,Object>> group(String json) throws Exception{

        JsonNode root=MAPPER.readTree(json);
        List<Chunk> chunks=new ArrayList<>();

        for(JsonNode n: root.path("chunks")){
            JsonNode b=n.path("grounding").path("box");
            if(b.isMissingNode()) continue;

            chunks.add(new Chunk(
                    n.path("id").asText(),
                    n.path("type").asText(),
                    n.path("markdown").asText(),
                    new Box(
                            b.path("left").asDouble(),
                            b.path("top").asDouble(),
                            b.path("right").asDouble(),
                            b.path("bottom").asDouble()
                    )
            ));
        }

        Map<Integer,List<Integer>> graph=buildGraph(chunks);

        boolean[] visited=new boolean[chunks.size()];
        List<Map<String,Object>> result=new ArrayList<>();

        for(int i=0;i<chunks.size();i++){

            if(visited[i]) continue;

            List<Chunk> document=new ArrayList<>();
            dfs(i,graph,visited,chunks,document);

            document.sort(
                    Comparator.comparingDouble((Chunk c)->c.box.top)
                            .thenComparingDouble(c->c.box.left)
            );

            Map<String,Object> map=new LinkedHashMap<>();

            map.put("boundingBox",merge(document));

            map.put("markdown",
                    document.stream()
                            .map(Chunk::markdown)
                            .collect(Collectors.joining("\n\n")));

            map.put("type","unknown");

            List<Map<String,Object>> chunkMaps=new ArrayList<>();

            for(Chunk c:document){

                Map<String,Object> cm=new LinkedHashMap<>();

                cm.put("id",c.id);
                cm.put("type",c.type);
                cm.put("markdown",c.markdown);

                Map<String,Object> bb=new LinkedHashMap<>();
                bb.put("left",c.box.left);
                bb.put("top",c.box.top);
                bb.put("right",c.box.right);
                bb.put("bottom",c.box.bottom);

                cm.put("boundingBox",bb);

                chunkMaps.add(cm);
            }

            map.put("chunks",chunkMaps);

            result.add(map);
        }

        return result;
    }

    private static Map<Integer,List<Integer>> buildGraph(List<Chunk> chunks){

        Map<Integer,List<Integer>> g=new HashMap<>();

        for(int i=0;i<chunks.size();i++){

            g.putIfAbsent(i,new ArrayList<>());

            for(int j=i+1;j<chunks.size();j++){

                if(score(chunks.get(i),chunks.get(j))>=SCORE_THRESHOLD){

                    g.get(i).add(j);

                    g.computeIfAbsent(j,k->new ArrayList<>()).add(i);
                }
            }
        }

        return g;
    }

    private static void dfs(
            int node,
            Map<Integer,List<Integer>> graph,
            boolean[] visited,
            List<Chunk> chunks,
            List<Chunk> out){

        if(visited[node]) return;

        visited[node]=true;

        out.add(chunks.get(node));

        for(Integer next:graph.getOrDefault(node,List.of()))
            dfs(next,graph,visited,chunks,out);
    }

    private static double score(Chunk a,Chunk b){

        double score=0;

        if(distance(a,b)<DISTANCE_THRESHOLD)
            score+=5;

        if(Math.abs(a.box.cy()-b.box.cy())<ROW_THRESHOLD)
            score+=2;

        if(Math.abs(a.box.cx()-b.box.cx())<COLUMN_THRESHOLD)
            score+=2;

        if(overlap(a.box,b.box))
            score+=5;

        return score;
    }

    private static double distance(Chunk a,Chunk b){

        double dx=a.box.cx()-b.box.cx();
        double dy=a.box.cy()-b.box.cy();

        return Math.sqrt(dx*dx+dy*dy);
    }

    private static boolean overlap(Box a,Box b){

        return !(a.right<b.left ||
                a.left>b.right ||
                a.bottom<b.top ||
                a.top>b.bottom);
    }

    private static Map<String,Object> merge(List<Chunk> chunks){

        double left=Double.MAX_VALUE;
        double top=Double.MAX_VALUE;
        double right=Double.MIN_VALUE;
        double bottom=Double.MIN_VALUE;

        for(Chunk c:chunks){

            left=Math.min(left,c.box.left);
            top=Math.min(top,c.box.top);
            right=Math.max(right,c.box.right);
            bottom=Math.max(bottom,c.box.bottom);
        }

        Map<String,Object> m=new LinkedHashMap<>();
        m.put("left",left);
        m.put("top",top);
        m.put("right",right);
        m.put("bottom",bottom);

        return m;
    }
}
