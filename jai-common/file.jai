#import "Basic";
#import "File";

#import,file "./string.jai";

file_read_all_as_string :: (filename: string) -> (string, bool) {
   file, success := file_open(filename, for_writing=false, keep_existing_content=true);
   if !success {
      log("Failed to open file '%' for reading", filename);
      return "", false;
   }

   length := file_length(file);
   buffer := cast(*u8) alloc(length);
   success = file_read(file, buffer, length);
   if !success {
      log("Failed to read data from file '%'", filename);
      return "", false;
   }

   file_close(*file);

   // create a string to hold the contents
   data: string;
   data.data = buffer;
   data.count = length;

   return data, true;
}

File_Contents :: struct {
    string_contents: string;
}

for_expansion :: (contents: File_Contents, body: Code, flags: For_Flags) #expand {
    line: string;
    line_index := 0;
    remainder := contents.string_contents;
    while remainder.count {
        line, remainder = string_next_line(remainder);
        `it_index := line_index;
        `it := line;
        line_index += 1;

        #insert body;
    }
}

file_read_all :: (filename: string) -> File_Contents {
    string_contents, success := file_read_all_as_string(filename);
    assert(success);

    contents: File_Contents;
    contents.string_contents = string_contents;

    return contents;
}
