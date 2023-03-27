pub const html_start = 
\\<!DOCTYPE html>
\\<html lang="en">
\\   <head>
\\      <meta charset="UTF-8">
\\      <meta http-equiv="X-UA-Compatible" content="IE=edge">
\\      <meta name="viewport" content="width=device-width, initial-scale=1.0">
;
// insert title

pub const head_end = 
\\      <link rel="stylesheet" href="https://cdn.simplecss.org/simple.css">
\\  </head>
\\<body class="bg-slate-800">
\\    <div class="container xl mx-auto">
;

pub const header_start = 
\\<header class="flex flex-row items-center h-24 w-auto bg-slate-300">
\\    <nav class="flex flex-row items-center h-10 w-full">
;

pub const header_end = 
\\    </ul>
\\</div>
\\</nav>
\\</header>
;
// inset main
pub const main_start = 
\\<main class="flex justify-center h-auto">
\\    <!-- 版心 -->
\\    <div class="my-4 w-4/5 h-full bg-slate-100">
\\        <!-- content -->
\\        <div class="py-2">
;

pub const main_end = 
\\</div>
\\</div>
\\</main>
;
// inset footer

pub const footer_start =
\\<footer class="h-64 mt-4 bg-slate-300">
;

pub const html_end = 
\\    </div>
\\</body>
\\</html>
;