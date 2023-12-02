#import "Basic";

// for_expansion for iterating characters of a string
chars :: (line: *string, body: Code, flags: For_Flags) #expand {
    reverse := flags & .REVERSE;
    start  := ifx !reverse then 0         else line.count-1;
    end    := ifx !reverse then line.count else -1;
    update := ifx !reverse then 1          else -1;

    i := start;
    while i != end {
        defer i += update;

        `it_index := i;
        `it := line.*[i];

        #insert body;
    }
}

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

