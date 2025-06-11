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
                    <form class="space-y-6" @submit.prevent="submitForm()">
                        <!-- Email Field -->
                        <div class="form-control">
                            <label class="label">
                                <span class="label-text font-medium">Email <span class="text-error">*</span></span>
                            </label>
                            <label class="input input-bordered flex items-center gap-2 w-full" 
                                   :class="{ 'input-error': errors.email }">
                                <i data-lucide="mail" class="h-4 w-4 opacity-70"></i>
                                <input 
                                    type="email" 
                                    x-model="formData.email"
                                    class="grow" 
                                    placeholder="example@company.com"
                                    required
                                    autocomplete="email"
                                />
                            </label>
                            <label class="label" x-show="errors.email">
                                <span class="label-text-alt text-error" x-text="errors.email"></span>
                            </label>
                        </div>

                        <!-- Password Field -->
                        <div class="form-control">
                            <label class="label">
                                <span class="label-text font-medium">Mật khẩu <span class="text-error">*</span></span>
                            </label>
                            <label class="input input-bordered flex items-center w-full gap-2" 
                                   :class="{ 'input-error': errors.password }">
                                <i data-lucide="lock" class="h-4 w-4 opacity-70"></i>
                                <input 
                                    :type="showPassword ? 'text' : 'password'"
                                    x-model="formData.password"
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
                            <label class="label" x-show="errors.password">
                                <span class="label-text-alt text-error" x-text="errors.password"></span>
                            </label>
                        </div>

                        <!-- Remember me & Forgot password -->
                        <div class="flex items-center justify-between">
                            <label class="label cursor-pointer gap-2">
                                <input type="checkbox" x-model="formData.remember" class="checkbox checkbox-primary checkbox-sm" />
                                <span class="label-text">Ghi nhớ đăng nhập</span>
                            </label>
                            <a href="/forgot-password" class="link link-primary text-sm">
                                Quên mật khẩu?
                            </a>
                        </div>

                        <!-- Submit Button -->
                        <button type="submit" class="btn btn-primary w-full" :disabled="loading">
                            <span x-show="loading" class="loading loading-spinner loading-sm"></span>
                            <span x-show="!loading" class="flex items-center gap-2">
                                <i data-lucide="log-in" class="h-5 w-5"></i>
                                Đăng nhập
                            </span>
                        </button>

                        <!-- Register Link -->
                        <div class="text-center">
                            <p class="text-sm text-gray-600">
                                Chưa có tài khoản?
                                <a href="/register" class="link link-primary font-medium">
                                    Đăng ký ngay
                                </a>
                            </p>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Footer -->
            <div class="text-center">
                <p class="text-xs text-gray-500">
                    © 2024 Ship Management System. All rights reserved.
                </p>
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
                loading: false,
                formData: {
                    email: '',
                    password: '',
                    remember: false
                },
                errors: {},
                notifications: [],

                async submitForm() {
                    this.loading = true;
                    this.errors = {};

                    // Client-side validation
                    if (!this.formData.email.trim()) {
                        this.errors.email = 'Email là bắt buộc';
                        this.loading = false;
                        return;
                    }

                    if (!this.formData.password.trim()) {
                        this.errors.password = 'Mật khẩu là bắt buộc';
                        this.loading = false;
                        return;
                    }

                    try {
                        const response = await fetch('/api/auth/login', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/json',
                            },
                            body: JSON.stringify(this.formData)
                        });

                        const data = await response.json();

                        if (data.success) {
                            this.showNotification('success', data.message, 'check-circle');
                            // Navigate to home page on successful login
                            setTimeout(() => {
                                window.location.href = '/';
                            }, 1000);
                        } else {
                            this.showNotification('error', data.message, 'alert-triangle');
                        }
                    } catch (error) {
                        this.showNotification('error', 'Lỗi kết nối: ' + error.message, 'alert-triangle');
                    } finally {
                        this.loading = false;
                        // Re-initialize Lucide icons after DOM changes
                        this.$nextTick(() => lucide.createIcons());
                    }
                },

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

        // Initialize Lucide icons on page load
        document.addEventListener('DOMContentLoaded', function() {
            lucide.createIcons();
        });
    </script>
</body>
</html>
