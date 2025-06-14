<!DOCTYPE html>
<html lang="vi" data-theme="corporate">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ship Management System - Login</title>
    <%-- tailwind css link --%>
    <link rel="stylesheet" href="styles/main.css" />
    <link rel="preconnect" href="https://fonts.bunny.net" />
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

</head>
<body class="min-h-screen bg-gradient-to-br from-blue-50 to-cyan-100">
    <div class="min-h-screen flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
        <div class="max-w-md w-full space-y-8" x-data="loginForm()">
            <!-- Header -->
            <div class="text-center">
                <div class="avatar">
                    <div class="w-16 h-16 rounded-full bg-primary !flex items-center justify-center mb-4 mx-auto">
                        <i data-lucide="ship" class="h-8 w-8 text-primary-content"></i>
                    </div>
                </div>
                <h2 class="text-3xl font-bold text-gray-900">
                    Đăng nhập hệ thống
                </h2>
                <p class="mt-2 text-sm text-gray-600">
                    Hệ thống quản lý tàu thuyền
                </p>
            </div>

            <!-- Login Form Card -->
            <div class="card bg-base-100 shadow-xl">
                <div class="card-body">
                    <!-- Spring Security Login Form -->
                    <form action="/login" method="POST" class="space-y-6">
                        <!-- Email Field -->
                        <div class="form-control">
                            <label class="label">
                                <span class="label-text font-medium">Email <span class="text-error">*</span></span>
                            </label>
                            <label class="input input-bordered flex items-center gap-2 w-full">
                                <i data-lucide="mail" class="h-4 w-4 opacity-70"></i>
                                <input 
                                    type="email" 
                                    name="email"
                                    class="grow" 
                                    placeholder="example@company.com"
                                    required
                                    autocomplete="email"
                                />
                            </label>
                        </div>

                        <!-- Password Field -->
                        <div class="form-control">
                            <label class="label">
                                <span class="label-text font-medium">Mật khẩu <span class="text-error">*</span></span>
                            </label>
                            <label class="input input-bordered flex items-center w-full gap-2">
                                <i data-lucide="lock" class="h-4 w-4 opacity-70"></i>
                                <input 
                                    :type="showPassword ? 'text' : 'password'"
                                    name="password"
                                    class="grow" 
                                    placeholder="••••••••"
                                    required
                                    minlength="4"
                                    autocomplete="current-password"
                                />
                                <button 
                                    type="button"
                                    @click="showPassword = !showPassword"
                                    class="btn btn-ghost btn-xs btn-square"
                                >
                                    <i :data-lucide="showPassword ? 'eye-off' : 'eye'" class="h-4 w-4 opacity-70"></i>
                                </button>
                            </label>
                        </div>

                        <!-- Remember me & Forgot password -->
                        <div class="flex items-center justify-start">
                            <label class="label cursor-pointer gap-2">
                                <input type="checkbox" name="remember-me" class="checkbox checkbox-primary checkbox-sm" />
                                <span class="label-text">Ghi nhớ đăng nhập</span>
                            </label>
                          
                        </div>

                        <!-- Submit Button -->
                        <button type="submit" class="btn btn-primary w-full">
                            <span class="flex items-center gap-2">
                                <i data-lucide="log-in" class="h-5 w-5"></i>
                                Đăng nhập
                            </span>
                        </button>

                     
                    </form>
                </div>
            </div>

         
        </div>
    </div>

    <!-- Toast Notifications Container -->
    <div class="toast toast-top toast-end z-50">
        <template x-for="notification in notifications" :key="notification.id">
            <div class="alert shadow-lg" :class="'alert-' + notification.type">
                <div class="flex items-center gap-2">
                    <i :data-lucide="notification.icon" class="w-5 h-5 flex-shrink-0"></i>
                    <span x-text="notification.message" class="flex-grow"></span>
                    <button @click="removeNotification(notification.id)" class="btn btn-ghost btn-sm btn-square">
                        <i data-lucide="x" class="w-4 h-4"></i>
                    </button>
                </div>
            </div>
        </template>
    </div>
    
    <script src="https://unpkg.com/lucide@latest"></script>
    <script>
        function loginForm() {
            return {
                showPassword: false,
                notifications: [],

                showNotification(type, message, icon) {
                    const notification = {
                        id: Date.now(),
                        type: type,
                        message: message,
                        icon: icon
                    };
                    
                    this.notifications.push(notification);
                    
                    // Auto-remove notification after 5 seconds
                    setTimeout(() => {
                        this.removeNotification(notification.id);
                    }, 5000);
                },

                removeNotification(id) {
                    this.notifications = this.notifications.filter(n => n.id !== id);
                }
            }
        }

        // Show notifications based on URL parameters
        document.addEventListener('DOMContentLoaded', function() {
            lucide.createIcons();
            
            const urlParams = new URLSearchParams(window.location.search);
            const loginForm = window.Alpine ? Alpine.evaluate(document.querySelector('[x-data="loginForm()"]'), 'loginForm()') : null;
            
            if (urlParams.has('error')) {
                if (loginForm) {
                    loginForm.showNotification('error', 'Email hoặc mật khẩu không đúng', 'alert-triangle');
                }
            }
            
            if (urlParams.has('logout')) {
                if (loginForm) {
                    loginForm.showNotification('success', 'Đăng xuất thành công', 'check-circle');
                }
            }
        });
    </script>
</body>
</html>
