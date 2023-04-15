pub const script_start =
    \\<script>
    \\        const routes = {
    \\            "/home": "./index.html",
    \\            "/about": "./about.html",
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
    \\ clickList.forEach(link => {
    \\   link.addEventListener("click", async e => {
    \\       e.preventDefault();
    \\         const url = e.target.dataset["href"];
    \\   //window.history.pushState({}, "", url);
    \\     if(e.target.tagName === "A") {
    \\      const html = await handleLocation(url);
    \\      if (url === "/home") {
    \\       window.location.reload();
    \\    }
    \\    if (url !== "/home" || url !== "/about") {
    \\       btn.style.display = "block";
    \\   }
    \\   content.innerHTML = html;
    \\  }
    \\  });
    \\});
    \\    window.onload = function() {
    \\  const localData = {
    \\    contents: [],
    \\  };
    \\  sectionLiAList.forEach(sec => {
    \\    localData.contents.push(sec.innerHTML);
    \\  });
    \\   window.localStorage.setItem("bodyContent",JSON.stringify(localData));
    \\ };
    \\ btn.addEventListener("click",e => {
    \\ btn.style.display = "none";
    \\ content.innerHTML = "";
    \\ [...sectionLiAList].forEach(section => {
    \\        content.appendChild(section);
    \\     });
    \\});
    \\    </script>
;
