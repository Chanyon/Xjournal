pub const script_start =
    \\<script>
    \\        const routes = {
    \\            "/home": "./index.html",
    \\            "/about": "./index.html",
;
// };
pub const script_end =
    \\       async function handleLocation(path) {
    \\            const route = routes[path] /*|| routes[404];*/
    \\            const html = await fetch(route).then(data => data.text());
    \\            return html;
    \\       }
    \\       const navList = document.querySelectorAll("nav ul li");
    \\       const sectionLiAList = document.querySelectorAll("section> ul li");
    \\       const clickList = [...navList, ...sectionLiAList];
    \\       clickList.forEach(link => {
    \\            link.addEventListener("click", async e => {
    \\                e.preventDefault();
    \\                console.log(1);
    \\                const url = e.target.dataset["href"];
    \\                //window.history.pushState({}, "", url);
    \\                const html = await handleLocation(url);
    \\                if (url === "/home") {
    \\                    document.body.innerHTML = html;
    \\                    window.location.reload();
    \\                }
    \\            });
    \\        });
    \\    </script>
;
