@param String title
@param String activePage = ""
@param gg.jte.Content content

<!DOCTYPE html>
<html lang="vi" data-theme="corporate">
<head>
    <title>${title}</title>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="preconnect" href="https://fonts.bunny.net" />
    <%-- tailwind css link --%>
    <link rel="stylesheet" href="styles/main.css" /> 
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
<body class="bg-base-200" x-data="{ sidebarOpen: false }">
    <div class="drawer lg:drawer-open">
        <input id="drawer-toggle" type="checkbox" class="drawer-toggle" x-model="sidebarOpen" />
        
        <!-- Sidebar -->
        <div class="drawer-side">
            <label for="drawer-toggle" class="drawer-overlay" @click="sidebarOpen = false"></label>
            <aside class="min-h-full w-60 bg-base-100 text-base-content">
                <!-- Sidebar Header -->
                <div class="p-4 border-b border-base-300">
                    <div class="flex items-center space-x-3">
                        <div class="w-10 h-10 bg-primary rounded-lg flex items-center justify-center">
                            <i data-lucide="ship" class="w-6 h-6 text-primary-content"></i>
                        </div>
                        <div>
                            <h1 class="text-xl font-bold">Ship Manager</h1>
                            <p class="text-xs text-base-content/70">Hệ thống quản lý tàu</p>
                        </div>
                    </div>
                </div>

                <!-- Navigation Menu -->
                <nav class="p-4">
                    <ul class="menu menu-vertical space-y-2">
                        <!-- Dashboard -->
                        <li>
                            <a href="/dashboard" class="flex items-center space-x-3 ${activePage.equals("dashboard") ? "active" : ""}">
                                <i data-lucide="gauge" class="w-5 h-5"></i>
                                <span>Dashboard</span>
                            </a>
                        </li>

                        <!-- Ships Management -->
                        <li>
                            <a href="/ships" class="flex items-center space-x-3 ${activePage.equals("ships") ? "active" : ""}">
                                <i data-lucide="ship" class="w-5 h-5"></i>
                                <span>Quản lý tàu</span>
                            </a>
                        </li>

                        <!-- User Management -->
                        <li>
                            <a href="/users" class="flex items-center space-x-3 ${activePage.equals("users") ? "active" : ""}">
                                <i data-lucide="users" class="w-5 h-5"></i>
                                <span>Quản lý người dùng</span>
                            </a>
                        </li>

                        <!-- Company Management -->
                        <li>
                            <a href="/companies" class="flex items-center space-x-3 ${activePage.equals("companies") ? "active" : ""}">
                                <i data-lucide="building" class="w-5 h-5"></i>
                                <span>Quản lý công ty</span>
                            </a>
                        </li>

                        <!-- Role Management -->
                        <li>
                            <a href="/roles" class="flex items-center space-x-3 ${activePage.equals("roles") ? "active" : ""}">
                                <i data-lucide="shield-check" class="w-5 h-5"></i>
                                <span>Quản lý vai trò</span>
                            </a>
                        </li>
                    </ul>
                </nav>

                <!-- User Profile -->
                <div class="absolute bottom-0 left-0 right-0 p-4 border-t border-base-300">
                    <div class="dropdown dropdown-top dropdown-end w-full">
                        <label tabindex="0" class="btn btn-ghost w-full justify-start">
                            <div class="avatar">
                                <div class="w-8 h-8 rounded-full">
                                    <img src="https://ui-avatars.com/api/?name=Admin&background=0d9488&color=fff" alt="User Avatar" />
                                </div>
                            </div>
                            <div class="text-left">
                                <div class="font-medium">Admin User</div>
                                <div class="text-xs text-base-content/70">admin@shipmanager.com</div>
                            </div>
                        </label>
                        <ul tabindex="0" class="dropdown-content menu p-2 shadow bg-base-100 rounded-box w-52 mb-2">
                            <li><a href="/profile"><i data-lucide="user" class="w-4 h-4"></i> Hồ sơ</a></li>
                            <li><a href="/preferences"><i data-lucide="settings" class="w-4 h-4"></i> Tùy chọn</a></li>
                            <li><hr class="my-2"></li>
                            <li><a href="/logout" class="text-error"><i data-lucide="log-out" class="w-4 h-4"></i> Đăng xuất</a></li>
                        </ul>
                    </div>
                </div>
            </aside>
        </div>

        <!-- Main Content -->
        <div class="drawer-content flex flex-col">
            <!-- Header -->
            <header class="navbar bg-base-100 border-b border-base-300 px-4">
                <div class="flex-none lg:hidden">
                    <label for="drawer-toggle" class="btn btn-square btn-ghost" @click="sidebarOpen = !sidebarOpen">
                        <i data-lucide="menu" class="w-6 h-6"></i>
                    </label>
                </div>
                
                <div class="flex-1">
                    <h1 class="text-xl font-semibold">${title}</h1>
                </div>
                
                <div class="flex-none space-x-2">
                  
                    
                   
                </div>
            </header>

            <!-- Page Content -->
            <main class="flex-1 p-6">
                ${content}
            </main>
        </div>
    </div>

    <script src="https://unpkg.com/lucide@latest"></script>
    <script>
        lucide.createIcons();
        
        // Auto-close sidebar on mobile when clicking nav links
        document.addEventListener('DOMContentLoaded', function() {
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
