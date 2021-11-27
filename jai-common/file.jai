#import "Basic";
#import "File";

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

