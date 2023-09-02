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
    \\<link rel="stylesheet" href="https://cdn.simplecss.org/simple.css">
    \\<link rel="stylesheet" href="https://unpkg.com/transition-style">
    \\<!-- <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/holiday.css@0.11.0" /> -->
    \\<link rel="stylesheet"href="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.7.0/build/styles/agate.min.css">
    \\<script src="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.7.0/build/highlight.min.js"></script>
    \\<style>
    \\ul li {
    \\  font-size: 20px;
    \\}
    \\  a:hover{
    \\    cursor: pointer;
    \\  }
    \\  #btn{
    \\      display: none;
    \\  }
    \\  .pub-date {
    \\      font-size: 14px;  
    \\  }
    \\  @media screen and (min-width: 1024px) {
    \\    body {
    \\      display: flex;
    \\      flex-direction: column;
    \\     justify-content: center;
    \\     align-items: center;
    \\   }
    \\   #content article {
    \\    width: 1024px;
    \\  }
    \\  .container {
    \\    width: 1024px;
    \\  }
    \\}
    \\h1,h2,h3,h4,h5,h6{margin: 15px 0;}
    \\h1 {font-size: 24px;}
    \\h2 {font-size: 22px;}
    \\h3 {font-size: 20px;}
    \\h4 {font-size: 18px;}
    \\h5 {font-size: 16px;}
    \\h6 {font-size: 14px;}
    \\.article_title {
    \\  border-bottom: 1px solid #898EA4;
    \\}
    \\</style>
    \\    <style>
    \\:root{
    \\    --nav-width: 24em;
    \\    --nav-margin-l: 1em;
    \\}
    \\#contents {
    \\    max-width: 60em;
    \\    margin: auto;
    \\    padding: 0 1em;
    \\}
    \\table, td {
    \\    border-collapse: collapse;
    \\    border: 1px solid grey;
    \\    text-align:left;
    \\    vertical-align:middle;
    \\}
    \\td {
    \\    padding: 0.1em;
    \\}
    \\.file {
    \\    font-weight: bold;
    \\    border: unset;
    \\}
    \\code {
    \\    background: #f8f8f8;
    \\    border: 1px dotted silver;
    \\  padding-left: 0.3em;
    \\  padding-right: 0.3em;
    \\}
    \\pre > code {
    \\  display: block;
    \\  overflow: auto;
    \\  padding: 0.5em;
    \\  border: 1px solid #eee;
    \\  line-height: normal;
    \\}
    \\figure {
    \\  margin: auto 0;
    \\}
    \\figure pre {
    \\  margin-top: 0;
    \\}
    \\figcaption {
    \\  padding-left: 0.5em;
    \\ font-size: small;
    \\ border-top-left-radius: 5px;
    \\ border-top-right-radius: 5px;
    \\}
    \\figcaption.zig-cap {
    \\  background: #fcdba5;
    \\}
    \\figcaption.c-cap {
    \\  background: #a8b9cc;
    \\color: #000;
    \\}
    \\figcaption.shell-cap {
    \\  background: #ccc;
    \\ color: #000;
    \\}
    \\aside {
    \\  border-left: 0.25em solid #f7a41d;
    \\  padding: 0 1em 0 1em;
    \\}
    \\h1 a, h2 a, h3 a, h4 a, h5 a, h6 a {
    \\    text-decoration: none;
    \\    color: #333;
    \\}
    \\a.hdr {
    \\   visibility: hidden;
    \\}
    \\h1:hover > a.hdr, h2:hover > a.hdr, h3:hover > a.hdr, h4:hover > a.hdr, h5:hover > a.hdr, h6:hover > a.hdr {
    \\    visibility: visible;
    \\}
    \\pre {
    \\    counter-reset: line;
    \\}
    \\pre .line:before {
    \\   counter-increment: line;
    \\ content: counter(line);
    \\display: inline-block;
    \\ padding-right: 1em;
    \\ width: 2em;
    \\ text-align: right;
    \\ color: #999;
    \\}
    \\</style>
    \\  </head>
    \\<body class="bg-slate-800">
    \\    <div class="container">
;

pub const header_start =
    \\<header>
    \\<nav>
;

pub const header_end =
    \\    </ul>
    \\</div>
    \\</nav>
    \\</header>
;
// inset main
pub const main_start =
    \\<main>
    \\    <!-- 版心 -->
    \\    <div>
    \\        <!-- content -->
    \\        <div><button id="btn">返回</button></div>
    \\        <div class="py-2" id="content" transition-style="in:circle:center">   
;

pub const main_end =
    \\</div>
    \\</div>
    \\</main>
;
// inset footer

pub const footer_start =
    \\<footer>
;

pub const html_end =
    \\</body>
    \\</html>
;

pub const main_article_start =
    \\<main transition-style="in:wipe:down">
    \\<article>
    \\<div>
;

pub const main_article_end =
    \\</article>
    \\</main>
;
