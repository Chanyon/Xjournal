pub const script_start =
    \\<script>
    \\        const routes = {
    \\            "/home": "./index.html",
;
// };
pub const script_end =
    \\       async function handleLocation(path) {
    \\            const route = routes[path] /*|| routes[404];*/
    \\            const html = await fetch(route).then(data => data.text());
    \\            return html;
    \\       }
    \\       const btn = document.querySelector("#btn");
    \\       const navList = document.querySelectorAll("nav ul");
    \\       const sectionLiAList = document.querySelectorAll("section");
    \\       const content = document.querySelector("#content"); 
    \\       const clickList = [...navList, ...sectionLiAList];
    \\   hljs.configure({
    \\     ignoreUnescapedHTML: true,
    \\   });
    \\ clickList.forEach(link => {
    \\   link.addEventListener("click", async e => {
    \\       e.preventDefault();
    \\         const url = e.target.dataset["href"];
    \\     if(e.target.tagName === "A") {
    \\      const html = await handleLocation(url);
    \\      if (url === "/home") {
    \\       window.location.reload();
    \\       return;
    \\    }
    \\    if (url !== "/home") {
    \\       btn.style.display = "block";
    \\   }
    \\   content.innerHTML = html;
    \\   document.querySelectorAll('pre code').forEach((el) => {
    \\      hljs.highlightElement(el);
    \\   });
    \\  }
    \\  });
    \\});
    \\ //   window.onload = function() {
    \\ // const localData = {
    \\ //   contents: [],
    \\ // };
    \\ // sectionLiAList.forEach(sec => {
    \\ //   localData.contents.push(sec.innerHTML);
    \\ // });
    \\ //  window.localStorage.setItem("bodyContent",JSON.stringify(localData));
    \\ //};
    \\ btn.addEventListener("click",e => {
    \\ btn.style.display = "none";
    \\ content.innerHTML = "";
    \\ [...sectionLiAList].forEach(section => {
    \\        content.appendChild(section);
    \\     });
    \\});
    \\ </script>
;
