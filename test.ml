
module NoOpMonad = struct
  type 'a t = 'a

  let return a = a
  let bind x f = f x
end

module StringMonad = struct
  type 'a t = 
      { data : 'a;
	str : string }
  let return a = { data=a; str=""; }
  let bind x f =
    let newstr = f x.data in
    {newstr with str = x.str ^ newstr.str}

  let strwr x = 
    { data=(); str=x }
  let getstr x = x.str
  let getdata x = x.data
end

module Test = Iteratees.Iteratee(NoOpMonad)

let test = "PUT /file HTTP/1.1\nHost: example.com\nUser-agent: X\ncontent-type: text/plain\r\n\r\n"
let test2 = "GET / HTTP/1.0\nfoo\nbar\nbaz\n\n"

let test_noop () =
  let open Test in
      let mylines = 
	match extract_result_from_iteratee (enum_eof (enum_nchunk test2 5 read_lines)) with 
	  | Left mylines ->
	    Printf.printf "Left:\n"; mylines
	  | Right mylines -> 
	    Printf.printf "Right:\n"; mylines
      in
      List.iter (fun x -> Printf.printf "'%s'\n" x) mylines

module Test2 = Iteratees.Iteratee(Lwt)


