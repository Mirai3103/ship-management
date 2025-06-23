@import com.ship.management.entity.User
@import java.util.List
@import java.util.stream.Stream

@param String title
@param String activePage = ""
@param gg.jte.Content content

@param User currentUser = null
!{var rootRole = currentUser == null ? null : currentUser.getRole().getRootRole().toString();}
!{var permissions = currentUser.getListAuthorities();}
<!DOCTYPE html>
<html lang="vi" data-theme="corporate">
<head>
    <title>${title}</title>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="preconnect" href="https://fonts.bunny.net"/>
    <%-- tailwind css link --%>
    <link rel="stylesheet" href="styles/main.css"/>
    <link
            href="https://fonts.bunny.net/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap"
            rel="stylesheet"
    />
    <script
            defer
            src="https://cdn.jsdelivr.net/npm/@alpinejs/focus@3.x.x/dist/cdn.min.js"
    ></script>
    <script
            defer
            src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"
    ></script>
    <style>
        .active {
            background-color: #000;
            color: #fff;
        }
    </style>
</head>
<body class="bg-base-200" x-data="{ sidebarOpen: window.innerWidth > 1024, isMobile: window.innerWidth < 1024 }"
      @resize.window="isMobile = window.innerWidth < 1024">
<div class="drawer" :class="{ 'lg:drawer-open': sidebarOpen && !isMobile }">
    <input id="drawer-toggle" type="checkbox" class="drawer-toggle" x-model="sidebarOpen"/>

    <div class="drawer-side">
        <label for="drawer-toggle" class="drawer-overlay" @click="sidebarOpen = false"></label>
        <aside class="min-h-full w-72 bg-base-100 text-base-content">
            <div class="p-4 border-b border-base-300">
                <div class="flex items-center justify-between">
                    <div class="flex items-center space-x-3">
                        <div class="w-10 h-10 bg-primary rounded-lg flex items-center justify-center">
                            <i data-lucide="ship" class="w-6 h-6 text-primary-content"></i>
                        </div>
                        <div>
                            <h1 class="text-xl font-bold">Ship Manager</h1>
                            <p class="text-xs text-base-content/70">Hệ thống quản lý tàu</p>
                        </div>
                    </div>
                    <button
                            class="btn btn-ghost btn-sm lg:hidden"
                            @click="sidebarOpen = false"
                    >
                        <i data-lucide="x" class="w-4 h-4"></i>
                    </button>
                </div>
            </div>

            <nav class="p-4">
                <ul class="menu menu-vertical space-y-2">
                    <li>
                        <a href="/dashboard"
                           class="flex items-center space-x-3 ${activePage.equals("dashboard") ? "active" : ""}">
                            <i data-lucide="gauge" class="w-5 h-5"></i>
                            <span>Dashboard</span>
                        </a>
                    </li>

                    @if(Stream.of("ROLE_ADMIN", "SHIP_MANAGEMENT").anyMatch(permissions::contains))
                        <li>
                            <a href="/ships"
                               class="flex items-center space-x-3 ${activePage.equals("ships") ? "active" : ""}">
                                <i data-lucide="ship" class="w-5 h-5"></i>
                                <span>Quản lý tàu</span>
                            </a>
                        </li>
                    @endif
                    <li>
                        <a href="/reviews-ship"
                           class="flex items-center space-x-3 ${activePage.equals("reviews-ship") ? "active" : ""}">
                            <i data-lucide="star" class="w-5 h-5"></i>
                            <span>Kiểm tra & Đánh giá tàu</span>
                        </a>
                    </li>
                    @if(Stream.of("ROLE_ADMIN", "USER_MANAGEMENT").anyMatch(permissions::contains))
                        <li>
                            <a href="/users"
                               class="flex items-center space-x-3 ${activePage.equals("users") ? "active" : ""}">
                                <i data-lucide="users" class="w-5 h-5"></i>
                                <span>Quản lý người dùng</span>
                            </a>
                        </li>
                    @endif

                    @if(Stream.of("ROLE_ADMIN", "COMPANY_MANAGEMENT").anyMatch(permissions::contains))
                        <li>
                            <a href="/companies"
                               class="flex items-center space-x-3 ${activePage.equals("companies") ? "active" : ""}">
                                <i data-lucide="building" class="w-5 h-5"></i>
                                <span>Quản lý công ty</span>
                            </a>
                        </li>
                    @endif

                    @if(Stream.of("ROLE_ADMIN", "ROLE_MANAGEMENT").anyMatch(permissions::contains))
                        <li>
                            <a href="/roles"
                               class="flex items-center space-x-3 ${activePage.equals("roles") ? "active" : ""}">
                                <i data-lucide="shield-check" class="w-5 h-5"></i>
                                <span>Quản lý vai trò</span>
                            </a>
                        </li>
                    @endif
                </ul>
            </nav>

            <div class="absolute bottom-0 left-0 right-0 p-4 border-t border-base-300">
                <div class="dropdown dropdown-top dropdown-end w-full">
                    @if (currentUser != null)
                        <label tabindex="0" class="btn btn-ghost w-full justify-start">
                            <div class="avatar">
                                <div class="w-8 h-8 rounded-full">
                                    <img src="https://ui-avatars.com/api/?name=${currentUser.getUsername()}&background=0d9488&color=fff"
                                         alt="User Avatar"/>
                                </div>
                            </div>

                            <div class="text-left">
                                <div class="font-medium">${currentUser.getFullName()}</div>
                                <div class="text-xs text-base-content/70">${currentUser.getEmail()}</div>
                            </div>
                        </label>
                    @endif
                    <ul tabindex="0" class="dropdown-content menu p-2 shadow bg-base-100 rounded-box w-52 mb-2">
                       
                        <li><a href="/logout" class="text-error"><i data-lucide="log-out" class="w-4 h-4"></i> Đăng xuất</a>
                        </li>
                    </ul>
                </div>
            </div>
        </aside>
    </div>

    <div class="drawer-content flex flex-col">
        <header class="navbar bg-base-100 border-b border-base-300 px-4">
            <div class="flex-none">
                <button
                        class="btn btn-square btn-ghost"
                        @click="sidebarOpen = !sidebarOpen"
                        :title="sidebarOpen ? 'Ẩn sidebar' : 'Hiển thị sidebar'"
                >
                    <i data-lucide="menu" class="w-6 h-6"></i>
                </button>
            </div>

            <div class="flex-1 ml-4">
                <h1 class="text-xl font-semibold">${title}</h1>
            </div>

            <div class="flex-none space-x-2">
              
            </div>
        </header>

        <main class="flex-1 p-1 md:p-6">
            ${content}
        </main>
    </div>
</div>

<script src="https://unpkg.com/lucide@latest"></script>
<script>
    lucide.createIcons();


    document.addEventListener('DOMContentLoaded', function () {
        const navLinks = document.querySelectorAll('.drawer-side a[href]');
        navLinks.forEach(link => {
            link.addEventListener('click', () => {
                if (window.innerWidth < 1024) {
                    document.getElementById('drawer-toggle').checked = false;
                }
            });
        });
    });
</script>
</body>
</html>
