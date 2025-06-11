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
                <div class="mx-auto h-16 w-16 bg-primary rounded-full flex items-center justify-center mb-4">
                    <i data-lucide="ship" class="h-8 w-8 text-primary-content"></i>
                </div>
                <h2 class="text-3xl font-bold text-gray-900">
                    Đăng nhập hệ thống
                </h2>
                <p class="mt-2 text-sm text-gray-600">
                    Hệ thống quản lý tàu thuyền
                </p>
            </div>

            <!-- Login Form -->
            <div class="card bg-base-100 shadow-xl">
                <div class="card-body">
                    <form class="space-y-6" @submit.prevent="submitForm()">
                        <div class="space-y-4">
                            <!-- Email Field -->
                            <div class="form-control">
                                <label class="label">
                                    <span class="label-text font-medium">Email <span class="text-error">*</span></span>
                                </label>
                                <div class="relative">
                                        <i data-lucide="mail" class="h-5 w-5 text-gray-400"></i>
                                    <input 
                                        type="email" 
                                        x-model="formData.email"
                                        class="input input-bordered w-full pl-10" 
                                        :class="{ 'input-error': errors.email }"
                                        placeholder="example@company.com"
                                        required
                                        autocomplete="email"
                                    />
                                </div>
                                <label class="label" x-show="errors.email">
                                    <span class="label-text-alt text-error" x-text="errors.email"></span>
                                </label>
                            </div>

                            <!-- Password Field -->
                            <div class="form-control">
                                <label class="label">
                                    <span class="label-text font-medium">Mật khẩu <span class="text-error">*</span></span>
                                </label>
                                <div class="relative">
                                        <i data-lucide="lock" class="h-5 w-5 text-gray-400"></i>
                                    <input 
                                        :type="showPassword ? 'text' : 'password'"
                                        x-model="formData.password"
                                        class="input input-bordered w-full pl-10 pr-10" 
                                        :class="{ 'input-error': errors.password }"
                                        placeholder="••••••••"
                                        required
                                        minlength="6"
                                        autocomplete="current-password"
                                    />
                                    <div class="absolute inset-y-0 right-0 pr-3 flex items-center">
                                        <button 
                                            type="button"
                                            @click="showPassword = !showPassword"
                                            class="text-gray-400 hover:text-gray-600 focus:outline-none"
                                        >
                                            <i :data-lucide="showPassword ? 'eye-off' : 'eye'" class="h-5 w-5"></i>
                                        </button>
                                    </div>
                                </div>
                                <label class="label" x-show="errors.password">
                                    <span class="label-text-alt text-error" x-text="errors.password"></span>
                                </label>
                            </div>
                        </div>

                        <!-- Remember me & Forgot password -->
                        <div class="flex items-center justify-between">
                            <div class="form-control">
                                <label class="label cursor-pointer">
                                    <input type="checkbox" x-model="formData.remember" class="checkbox checkbox-primary checkbox-sm" />
                                    <span class="label-text ml-2">Ghi nhớ đăng nhập</span>
                                </label>
                            </div>
                            <div class="text-sm">
                                <a href="/forgot-password" class="font-medium text-primary hover:text-primary-focus">
                                    Quên mật khẩu?
                                </a>
                            </div>
                        </div>

                        <!-- Submit Button -->
                        <div>
                            <button type="submit" class="btn btn-primary w-full" :disabled="loading">
                                <span x-show="loading" class="loading loading-spinner loading-sm"></span>
                                <span x-show="!loading">
                                    <i data-lucide="log-in" class="h-5 w-5 mr-2"></i>
                                    Đăng nhập
                                </span>
                            </button>
                        </div>

                        <!-- Register Link -->
                        <div class="text-center">
                            <p class="text-sm text-gray-600">
                                Chưa có tài khoản?
                                <a href="/register" class="font-medium text-primary hover:text-primary-focus">
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

            <!-- Toast Notifications -->
            <div class="toast toast-top toast-end">
                <template x-for="notification in notifications" :key="notification.id">
                    <div class="alert" :class="'alert-' + notification.type">
                        <i :data-lucide="notification.icon" class="w-4 h-4"></i>
                        <span x-text="notification.message"></span>
                        <button @click="removeNotification(notification.id)" class="btn btn-ghost btn-xs">
                            <i data-lucide="x" class="w-3 h-3"></i>
                        </button>
                    </div>
                </template>
            </div>
        </div>
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
                        // Re-initialize Lucide icons
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
                    
                    setTimeout(() => {
                        this.removeNotification(notification.id);
                    }, 5000);
                },

                removeNotification(id) {
                    this.notifications = this.notifications.filter(n => n.id !== id);
                }
            }
        }

        // Initialize Lucide icons
        lucide.createIcons();
    </script>
</body>
</html>
