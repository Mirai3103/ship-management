<!DOCTYPE html>
<html lang="vi" data-theme="corporate">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ship Management System - Đăng ký</title>
    <%-- tailwind css link --%>
    <link rel="stylesheet" href="styles/main.css" />
    <link rel="preconnect" href="https://fonts.bunny.net" />
    <script src="https://unpkg.com/lucide@latest"></script>
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
        <div class="max-w-md w-full space-y-8" x-data="registerForm()">
            <!-- Header -->
            <div class="text-center">
                <div class="mx-auto h-16 w-16 bg-primary rounded-full flex items-center justify-center mb-4">
                    <i data-lucide="ship" class="h-8 w-8 text-primary-content"></i>
                </div>
                <h2 class="text-3xl font-bold text-gray-900">
                    Đăng ký tài khoản
                </h2>
                <p class="mt-2 text-sm text-gray-600">
                    Hệ thống quản lý tàu thuyền
                </p>
            </div>

            <!-- Registration Form -->
            <div class="card bg-base-100 shadow-xl">
                <div class="card-body">
                    <form class="space-y-6" @submit.prevent="submitForm()">
                        <div class="space-y-4">
                            <!-- Full Name Field -->
                            <div class="form-control">
                                <label class="label">
                                    <span class="label-text font-medium">Họ và tên <span class="text-error">*</span></span>
                                </label>
                                <div class="relative">
                                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                        <i data-lucide="user" class="h-5 w-5 text-gray-400"></i>
                                    </div>
                                    <input 
                                        type="text" 
                                        x-model="formData.fullName"
                                        class="input input-bordered w-full pl-10" 
                                        :class="{ 'input-error': errors.fullName }"
                                        placeholder="Nguyễn Văn A"
                                        required
                                        minlength="3"
                                        maxlength="100"
                                        autocomplete="name"
                                    />
                                </div>
                                <label class="label" x-show="errors.fullName">
                                    <span class="label-text-alt text-error" x-text="errors.fullName"></span>
                                </label>
                            </div>

                            <!-- Email Field -->
                            <div class="form-control">
                                <label class="label">
                                    <span class="label-text font-medium">Email <span class="text-error">*</span></span>
                                </label>
                                <div class="relative">
                                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                        <i data-lucide="mail" class="h-5 w-5 text-gray-400"></i>
                                    </div>
                                    <input 
                                        type="email" 
                                        x-model="formData.email"
                                        class="input input-bordered w-full pl-10" 
                                        :class="{ 'input-error': errors.email }"
                                        placeholder="example@company.com"
                                        required
                                        maxlength="100"
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
                                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                        <i data-lucide="lock" class="h-5 w-5 text-gray-400"></i>
                                    </div>
                                    <input 
                                        :type="showPassword ? 'text' : 'password'"
                                        x-model="formData.password"
                                        class="input input-bordered w-full pl-10 pr-10" 
                                        :class="{ 'input-error': errors.password }"
                                        placeholder="••••••••"
                                        required
                                        minlength="6"
                                        maxlength="100"
                                        autocomplete="new-password"
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

                            <!-- Confirm Password Field -->
                            <div class="form-control">
                                <label class="label">
                                    <span class="label-text font-medium">Xác nhận mật khẩu <span class="text-error">*</span></span>
                                </label>
                                <div class="relative">
                                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                        <i data-lucide="lock" class="h-5 w-5 text-gray-400"></i>
                                    </div>
                                    <input 
                                        :type="showConfirmPassword ? 'text' : 'password'"
                                        x-model="formData.confirmPassword"
                                        class="input input-bordered w-full pl-10 pr-10" 
                                        :class="{ 'input-error': errors.confirmPassword }"
                                        placeholder="••••••••"
                                        required
                                        minlength="6"
                                        autocomplete="new-password"
                                    />
                                    <div class="absolute inset-y-0 right-0 pr-3 flex items-center">
                                        <button 
                                            type="button"
                                            @click="showConfirmPassword = !showConfirmPassword"
                                            class="text-gray-400 hover:text-gray-600 focus:outline-none"
                                        >
                                            <i :data-lucide="showConfirmPassword ? 'eye-off' : 'eye'" class="h-5 w-5"></i>
                                        </button>
                                    </div>
                                </div>
                                <label class="label" x-show="errors.confirmPassword">
                                    <span class="label-text-alt text-error" x-text="errors.confirmPassword"></span>
                                </label>
                            </div>
                        </div>

                        <!-- Terms and Conditions -->
                        <div class="form-control">
                            <label class="label cursor-pointer justify-start">
                                <input type="checkbox" x-model="acceptTerms" class="checkbox checkbox-primary checkbox-sm" required />
                                <span class="label-text ml-2">
                                    Tôi đồng ý với 
                                    <a href="#" class="text-primary hover:text-primary-focus">điều khoản sử dụng</a>
                                    và 
                                    <a href="#" class="text-primary hover:text-primary-focus">chính sách bảo mật</a>
                                </span>
                            </label>
                        </div>

                        <!-- Submit Button -->
                        <div>
                            <button type="submit" class="btn btn-primary w-full" :disabled="loading">
                                <span x-show="loading" class="loading loading-spinner loading-sm"></span>
                                <span x-show="!loading">
                                    <i data-lucide="user-plus" class="h-5 w-5 mr-2"></i>
                                    Đăng ký
                                </span>
                            </button>
                        </div>

                        <!-- Login Link -->
                        <div class="text-center">
                            <p class="text-sm text-gray-600">
                                Đã có tài khoản?
                                <a href="/login" class="font-medium text-primary hover:text-primary-focus">
                                    Đăng nhập ngay
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

    <script>
        function registerForm() {
            return {
                showPassword: false,
                showConfirmPassword: false,
                loading: false,
                acceptTerms: false,
                formData: {
                    fullName: '',
                    email: '',
                    password: '',
                    confirmPassword: ''
                },
                errors: {},
                notifications: [],

                async submitForm() {
                    this.loading = true;
                    this.errors = {};

                    // Client-side validation matching UserRegistrationDTO constraints
                    if (!this.formData.fullName.trim()) {
                        this.errors.fullName = 'Tên là bắt buộc';
                        this.loading = false;
                        return;
                    }

                    if (this.formData.fullName.trim().length < 3 || this.formData.fullName.trim().length > 100) {
                        this.errors.fullName = 'Tên phải từ 3 đến 100 ký tự';
                        this.loading = false;
                        return;
                    }

                    if (!this.formData.email.trim()) {
                        this.errors.email = 'Email là bắt buộc';
                        this.loading = false;
                        return;
                    }

                    if (this.formData.email.trim().length > 100) {
                        this.errors.email = 'Email không được quá 100 ký tự';
                        this.loading = false;
                        return;
                    }

                    if (!this.formData.password.trim()) {
                        this.errors.password = 'Mật khẩu là bắt buộc';
                        this.loading = false;
                        return;
                    }

                    if (this.formData.password.trim().length < 6 || this.formData.password.trim().length > 100) {
                        this.errors.password = 'Mật khẩu phải từ 6 đến 100 ký tự';
                        this.loading = false;
                        return;
                    }

                    if (!this.formData.confirmPassword.trim()) {
                        this.errors.confirmPassword = 'Xác nhận mật khẩu là bắt buộc';
                        this.loading = false;
                        return;
                    }

                    if (this.formData.password !== this.formData.confirmPassword) {
                        this.errors.confirmPassword = 'Mật khẩu xác nhận không khớp';
                        this.loading = false;
                        return;
                    }

                    if (!this.acceptTerms) {
                        this.showNotification('error', 'Vui lòng đồng ý với điều khoản sử dụng', 'alert-triangle');
                        this.loading = false;
                        return;
                    }

                    try {
                        const response = await fetch('/api/auth/register', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/json',
                            },
                            body: JSON.stringify(this.formData)
                        });

                        const data = await response.json();

                        if (data.success) {
                            this.showNotification('success', data.message, 'check-circle');
                            // Redirect to login after successful registration
                            setTimeout(() => {
                                window.location.href = '/login?registered=true';
                            }, 2000);
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
