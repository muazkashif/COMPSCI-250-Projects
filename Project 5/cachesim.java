import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.Arrays;

public class cachesim {

    public static class Frame {
        boolean Valid;
        int Dirty;
        int BlockStart;
        int Tag;
        String[] Data;
        int Time;

        public Frame(int blocksize) {
            this.Valid = false;
            this.Dirty = 0;
            this.Data = new String[blocksize];
        }
    }

    public static void main (String [] args) {
        int time = 0;
        //Reading in input
        String tracefile = args[0];
        int cache_size = Integer.valueOf(args[1]);
        int assoc = Integer.valueOf(args[2]);
        String config = args[3];
        int block_size = Integer.valueOf(args[4]);

        //Creating cache
        int num_blocks = (cache_size * 1024) / block_size;
        int sets = num_blocks/assoc;
        Frame[][] Cache = new Frame[sets][assoc];
        for (int i = 0; i < sets; i++) {
            for (int j = 0; j < assoc; j++) {
                Cache[i][j] = new Frame(block_size);
            }
        }
        String[] Memory = new String[65536];
        Arrays.fill(Memory, "00");

        //reading file line by line
        BufferedReader reader;
        try {
            reader = new BufferedReader(new FileReader(tracefile));
            String line = reader.readLine();
            while (line != null) {
                String[] instruction = line.split(" ");
                //splitting instruction
                String type = instruction[0];
                String hex_address = instruction[1];
                int decimal_address = Integer.parseInt(instruction[1],16);
                int access_size;
                String value_to_store = "";
                if (type.equals("store")) {
                    access_size = Integer.valueOf(instruction[2]);
                    value_to_store = instruction[3].trim();
                }
                else {
                    access_size = Integer.valueOf(instruction[2].trim());
                }
                String ret = type + " " + hex_address;

                //searching for address in cache
                int block_offset = decimal_address % block_size;
                int index = (decimal_address / block_size) % sets;
                int tag = decimal_address / (sets * block_size);
                int startBlockIndex = decimal_address - block_offset;
                Frame[] set = Cache[index];
                int block_to_change_idx;

                if (setFull(set)) {  //check if set is full to see which block to write to on a miss
                    block_to_change_idx = findLRUIndex(set);
                }
                else {
                    block_to_change_idx = findEmptyIndex(set);
                }

                if (config.equals("wt")) {   //wt cache
                    if (type.equals("load")) {  //wt load
                        if (tagExists(set, tag)) {    //wt load HIT
                            ret += " hit";
                            int block_index = findBlockIndex(set, tag);
                            Frame block = set[block_index];
                            String[] data = block.Data;
                            String loaded_data = "";
                            for (int i = block_offset; i < block_offset + access_size; i++) {
                                loaded_data += data[i];
                            }
                            Cache[index][block_index].Time = time;
                            ret += " " + loaded_data;
                        }
                        else {    //wt load miss
                            ret += " miss";
                            //bring block up from memory no need to save evicted block
                            Cache[index][block_to_change_idx].Valid = true;
                            Cache[index][block_to_change_idx].BlockStart = startBlockIndex;
                            Cache[index][block_to_change_idx].Tag = tag;
                            Cache[index][block_to_change_idx].Time = time;
                            //move block data to cache
                            for (int i = 0; i < block_size; i++) {
                                Cache[index][block_to_change_idx].Data[i] = Memory[startBlockIndex + i];
                            }
                            //read loaded data
                            String[] data = Cache[index][block_to_change_idx].Data;
                            String loaded_data = "";
                            for (int i = block_offset; i < block_offset + access_size; i++) {
                                loaded_data += data[i];
                            }
                            Cache[index][block_to_change_idx].Time = time;
                            ret += " " + loaded_data;
                        }
                    }
                    else {       //wt store
                        if (tagExists(set, tag)) {    //wt store HIT
                            ret += " hit";
                            int block_index = findBlockIndex(set, tag);
                            //turning hex string into 1 byte chunks array
                            String[] Value_To_Store = new String[value_to_store.length()/2];
                            for (int i = 0; i < value_to_store.length(); i+=2) {
                                Value_To_Store[i/2] = value_to_store.split("")[i] + value_to_store.split("")[i+1];
                            }
                            //write to cache
                            for (int i = block_offset; i < block_offset + access_size; i++) {
                                Cache[index][block_index].Data[i] = Value_To_Store[i - block_offset];
                            }
                            Cache[index][block_index].Time = time;
                            //write to memory
                            for (int i = decimal_address; i < decimal_address + access_size; i++) {
                                Memory[i] = Value_To_Store[i - decimal_address];
                            }
                        }
                        else {    //wt store miss
                            ret += " miss";
                            //turning hex string into 1 byte chunks array
                            String[] Value_To_Store = new String[value_to_store.length()/2];
                            for (int i = 0; i < value_to_store.length(); i+=2) {
                                Value_To_Store[i/2] = value_to_store.split("")[i] + value_to_store.split("")[i+1];
                            }
                            //write to memory
                            for (int i = decimal_address; i < decimal_address + access_size; i++) {
                                Memory[i] = Value_To_Store[i - decimal_address];
                            }
                        }
                    }
                }
                else {     //wb cache
                    if (type.equals("load")) {  //wb load
                        if (tagExists(set, tag)) {    //wb load HIT
                            ret += " hit";
                            int block_index = findBlockIndex(set, tag);
                            Frame block = set[block_index];
                            String[] data = block.Data;
                            String loaded_data = "";
                            for (int i = block_offset; i < block_offset + access_size; i++) {
                                loaded_data += data[i];
                            }
                            Cache[index][block_index].Time = time;
                            ret += " " + loaded_data;
                        }
                        else {    //wb load miss
                            ret += " miss";
                            if (setFull(set) && (Cache[index][block_to_change_idx].Dirty==1)) { //save dirty
                                int startOfEviction = Cache[index][block_to_change_idx].BlockStart;
                                for (int i = startOfEviction; i < startOfEviction + block_size; i++) {
                                    Memory[i] = Cache[index][block_to_change_idx].Data[i-startOfEviction];
                                }
                            }
                            //bring block up from memory after saving evicted block if necessary
                            Cache[index][block_to_change_idx].Valid = true;
                            Cache[index][block_to_change_idx].BlockStart = startBlockIndex;
                            Cache[index][block_to_change_idx].Dirty = 0;
                            Cache[index][block_to_change_idx].Tag = tag;
                            Cache[index][block_to_change_idx].Time = time;
                            //move block data to cache
                            for (int i = 0; i < block_size; i++) {
                                Cache[index][block_to_change_idx].Data[i] = Memory[startBlockIndex + i];
                            }
                            //load data from newly filled block
                            int block_index = findBlockIndex(set, tag);
                            Frame block = set[block_index];
                            String[] data = block.Data;
                            String loaded_data = "";
                            for (int i = block_offset; i < block_offset + access_size; i++) {
                                loaded_data += data[i];
                            }
                            Cache[index][block_index].Time = time;
                            ret += " " + loaded_data;

                        }
                    }
                    else {       //wb store
                        if (tagExists(set, tag)) {    //wb store HIT
                            ret += " hit";
                            //write data to cache NOT memory
                            int block_index = findBlockIndex(set, tag);
                            //turning hex string into 1 byte chunks array
                            String[] Value_To_Store = new String[value_to_store.length()/2];
                            for (int i = 0; i < value_to_store.length(); i+=2) {
                                Value_To_Store[i/2] = value_to_store.split("")[i] + value_to_store.split("")[i+1];
                            }
                            //write to cache
                            for (int i = block_offset; i < block_offset + access_size; i++) {
                                Cache[index][block_index].Data[i] = Value_To_Store[i - block_offset];
                            }
                            Cache[index][block_index].Dirty = 1;
                            Cache[index][block_index].Time = time;
                        }
                        else {    //wb store miss
                            ret += " miss";
                            if (setFull(set) && (Cache[index][block_to_change_idx].Dirty==1)) { //save dirty
                                int startOfEviction = Cache[index][block_to_change_idx].BlockStart;
                                for (int i = startOfEviction; i < startOfEviction + block_size; i++) {
                                    Memory[i] = Cache[index][block_to_change_idx].Data[i-startOfEviction];
                                }
                            }
                            //bring block up from memory after saving evicted block if necessary
                            Cache[index][block_to_change_idx].Valid = true;
                            Cache[index][block_to_change_idx].BlockStart = startBlockIndex;
                            Cache[index][block_to_change_idx].Dirty = 0;
                            Cache[index][block_to_change_idx].Tag = tag;
                            Cache[index][block_to_change_idx].Time = time;
                            //move block data to cache
                            for (int i = 0; i < block_size; i++) {
                                Cache[index][block_to_change_idx].Data[i] = Memory[startBlockIndex + i];
                            }
                            //write data to cache and set dirty bit to 1; do NOT write to memory
                            //turning hex string into 1 byte chunks array
                            String[] Value_To_Store = new String[value_to_store.length()/2];
                            for (int i = 0; i < value_to_store.length(); i+=2) {
                                Value_To_Store[i/2] = value_to_store.split("")[i] + value_to_store.split("")[i+1];
                            }
                            //write to cache
                            for (int i = block_offset; i < block_offset + access_size; i++) {
                                Cache[index][block_to_change_idx].Data[i] = Value_To_Store[i - block_offset];
                            }
                            Cache[index][block_to_change_idx].Dirty = 1;
                            Cache[index][block_to_change_idx].Time = time;
                        }
                    }
                }




                System.out.println(ret);
                /* LOAD FROM CACHE CHECK
                String[] data = Cache[index][block_to_change_idx].Data;
                String loaded_data = "";
                for (int i = block_offset; i < block_offset + access_size; i++) {
                    loaded_data += data[i];
                }
                System.out.println(loaded_data);*/
                time++;
                // read next line
                line = reader.readLine();
            }
            reader.close();
        }
        catch (IOException e) {
            e.printStackTrace();
        }

    }
    private static boolean tagExists(Frame[] set, int tag) {
        for (Frame frame: set) {
            if (frame.Valid == true && frame.Tag == tag) {
                return true;
            }
        }
        return false;
    }
    private static int findBlockIndex(Frame[] set, int tag) {
        for (int i = 0; i < set.length; i++) {
            if (set[i].Valid == true && set[i].Tag == tag) {
                return i;
            }
        }
        return 0;
    }
    private static boolean setFull(Frame[] set) {
        for (Frame frame: set) {
            if (frame.Valid == false) {
                return false;
            }
        }
        return true;
    }
    private static int findEmptyIndex(Frame[] set) {
        for (int i = 0; i < set.length; i++) {
            if (set[i].Valid == false) {
                return i;
            }
        }
        return 0;
    }
    private static int findLRUIndex(Frame[] set) {
        int min = Integer.MAX_VALUE;
        int idx = 0;
        for (int i = 0; i < set.length; i++) {
            if (set[i].Time < min) {
                min = set[i].Time;
                idx = i;
            }
        }
        return idx;
    }
}

