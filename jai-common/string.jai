#import "Basic";

string_next_line :: (str: string) -> (string, string) {
   if (!str.count) return ("", "");

   // split on the first '\n' and discard the '\n'
   len := 0;
   while (len < str.count && str[len] != #char "\n")  len += 1;

   line: string;
   line.data = str.data;
   line.count = len;

   out_string: string;
   if (len == str.count && str[len - 1] != #char "\n") {
      out_string.data = null;
      out_string.count = 0;
   } else {
      out_string.data = str.data + len + 1;
      out_string.count = str.count - len - 1;
   }
   
   return (line, out_string);
}

