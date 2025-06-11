@template.layout(
    title = "Quản lý công ty",
    activePage = "companies",
    content = @`
        <div x-data="companyManager()" x-init="loadCompanies()" class="space-y-6">
            <!-- Header Section -->
            <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
                <div>
                    <h1 class="text-2xl font-bold">Quản lý công ty</h1>
                    <p class="text-base-content/70">Quản lý thông tin các công ty vận tải biển</p>
                </div>
                <button @click="openAddModal()" class="btn btn-primary">
                    <i data-lucide="plus" class="w-4 h-4"></i>
                    Thêm công ty mới
                </button>
            </div>

            <!-- Search and Filter Section -->
            <div class="card bg-base-100 shadow-xl">
                <div class="card-body">
                    <div class="flex flex-col lg:flex-row gap-4">
                        <!-- Search Input -->
                        <div class="flex-1">
                            <div class="form-control">
                                <div class="input-group">
                                    <input 
                                        type="text" 
                                        placeholder="Tìm kiếm theo tên công ty..." 
                                        class="input input-bordered flex-1"
                                        x-model="searchQuery"
                                        @input.debounce.300ms="searchCompanies()"
                                    />
                                    <button class="btn btn-square" @click="searchCompanies()">
                                        <i data-lucide="search" class="w-4 h-4"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Page Size Selector -->
                        <div class="form-control w-full max-w-xs">
                            <select class="select select-bordered" x-model="pageSize" @change="loadCompanies()">
                                <option value="5">5 công ty/trang</option>
                                <option value="10">10 công ty/trang</option>
                                <option value="20">20 công ty/trang</option>
                                <option value="50">50 công ty/trang</option>
                            </select>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Companies Table -->
            <div class="card bg-base-100 shadow-xl">
                <div class="card-body">
                    <div class="flex items-center justify-between mb-4">
                        <h2 class="card-title">
                            <i data-lucide="building-2" class="w-5 h-5"></i>
                            Danh sách công ty
                        </h2>
                        <div class="text-sm text-base-content/70" x-show="companies.totalElements">
                            Hiển thị <span x-text="companies.numberOfElements"></span> trên <span x-text="companies.totalElements"></span> công ty
                        </div>
                    </div>

                    <!-- Loading State -->
                    <div x-show="loading" class="flex justify-center py-8">
                        <span class="loading loading-spinner loading-lg"></span>
                    </div>

                    <!-- Empty State -->
                    <div x-show="!loading && companies.content && companies.content.length === 0" class="text-center py-8">
                        <i data-lucide="building-2" class="w-16 h-16 mx-auto text-base-content/30 mb-4"></i>
                        <h3 class="text-lg font-medium mb-2">Chưa có công ty nào</h3>
                        <p class="text-base-content/70 mb-4">Bắt đầu bằng cách thêm công ty đầu tiên</p>
                        <button @click="openAddModal()" class="btn btn-primary">
                            <i data-lucide="plus" class="w-4 h-4"></i>
                            Thêm công ty mới
                        </button>
                    </div>

                    <!-- Companies Table -->
                    <div x-show="!loading && companies.content && companies.content.length > 0" class="overflow-x-auto">
                        <table class="table table-zebra w-full">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Tên công ty</th>
                                    <th>Địa chỉ</th>
                                    <th>Điện thoại</th>
                                    <th>Email</th>
                                    <th>Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <template x-for="company in companies.content" :key="company.id">
                                    <tr>
                                        <td>
                                            <span class="font-mono text-sm" x-text="company.id"></span>
                                        </td>
                                        <td>
                                            <div class="flex items-center space-x-3">
                                                <div class="w-3 h-3 bg-primary rounded-full"></div>
                                                <span class="font-medium" x-text="company.name"></span>
                                            </div>
                                        </td>
                                        <td>
                                            <span x-text="company.address"></span>
                                        </td>
                                        <td>
                                            <span class="font-mono" x-text="company.phone"></span>
                                        </td>
                                        <td>
                                            <span class="text-primary" x-text="company.email"></span>
                                        </td>
                                        <td>
                                            <div class="flex items-center space-x-2">
                                                <button @click="viewCompany(company)" class="btn btn-ghost btn-xs tooltip" data-tip="Xem chi tiết">
                                                    <i data-lucide="eye" class="w-3 h-3"></i>
                                                </button>
                                                <button @click="editCompany(company)" class="btn btn-ghost btn-xs tooltip" data-tip="Chỉnh sửa">
                                                    <i data-lucide="edit" class="w-3 h-3"></i>
                                                </button>
                                                <button @click="deleteCompany(company)" class="btn btn-ghost btn-xs text-error tooltip" data-tip="Xóa">
                                                    <i data-lucide="trash-2" class="w-3 h-3"></i>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </template>
                            </tbody>
                        </table>
                    </div>

                    <!-- Pagination -->
                    <div x-show="!loading && companies.totalPages > 1" class="flex justify-center mt-6">
                        <div class="join">
                            <button 
                                class="join-item btn" 
                                :disabled="companies.first"
                                @click="changePage(currentPage - 1)"
                            >
                                <i data-lucide="chevron-left" class="w-4 h-4"></i>
                            </button>
                            
                            <template x-for="page in getVisiblePages()" :key="page">
                                <button 
                                    class="join-item btn"
                                    :class="page === currentPage ? 'btn-active' : ''"
                                    @click="changePage(page)"
                                    x-text="page + 1"
                                ></button>
                            </template>
                            
                            <button 
                                class="join-item btn" 
                                :disabled="companies.last"
                                @click="changePage(currentPage + 1)"
                            >
                                <i data-lucide="chevron-right" class="w-4 h-4"></i>
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Add/Edit Modal -->
            <div class="modal" :class="{ 'modal-open': showModal }">
                <div class="modal-box max-w-2xl">
                    <h3 class="font-bold text-lg mb-4">
                        <span x-show="!editingCompany">Thêm công ty mới</span>
                        <span x-show="editingCompany">Chỉnh sửa công ty</span>
                    </h3>
                    
                    <form @submit.prevent="saveCompany()" class="space-y-4">
                        <!-- Company Name -->
                        <div class="form-control">
                            <label class="label">
                                <span class="label-text">Tên công ty <span class="text-error">*</span></span>
                            </label>
                            <input 
                                type="text" 
                                placeholder="Nhập tên công ty" 
                                class="input input-bordered"
                                :class="{ 'input-error': errors.name }"
                                x-model="formData.name"
                                required
                            />
                            <label class="label" x-show="errors.name">
                                <span class="label-text-alt text-error" x-text="errors.name"></span>
                            </label>
                        </div>

                        <!-- Address -->
                        <div class="form-control">
                            <label class="label">
                                <span class="label-text">Địa chỉ <span class="text-error">*</span></span>
                            </label>
                            <textarea 
                                placeholder="Nhập địa chỉ công ty" 
                                class="textarea textarea-bordered h-20"
                                :class="{ 'textarea-error': errors.address }"
                                x-model="formData.address"
                                required
                            ></textarea>
                            <label class="label" x-show="errors.address">
                                <span class="label-text-alt text-error" x-text="errors.address"></span>
                            </label>
                        </div>

                        <!-- Phone and Email Row -->
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <!-- Phone -->
                            <div class="form-control">
                                <label class="label">
                                    <span class="label-text">Số điện thoại <span class="text-error">*</span></span>
                                </label>
                                <input 
                                    type="tel" 
                                    placeholder="0123456789" 
                                    class="input input-bordered"
                                    :class="{ 'input-error': errors.phone }"
                                    x-model="formData.phone"
                                    required
                                />
                                <label class="label" x-show="errors.phone">
                                    <span class="label-text-alt text-error" x-text="errors.phone"></span>
                                </label>
                            </div>

                            <!-- Email -->
                            <div class="form-control">
                                <label class="label">
                                    <span class="label-text">Email <span class="text-error">*</span></span>
                                </label>
                                <input 
                                    type="email" 
                                    placeholder="company@example.com" 
                                    class="input input-bordered"
                                    :class="{ 'input-error': errors.email }"
                                    x-model="formData.email"
                                    required
                                />
                                <label class="label" x-show="errors.email">
                                    <span class="label-text-alt text-error" x-text="errors.email"></span>
                                </label>
                            </div>
                        </div>

                        <div class="modal-action">
                            <button type="button" class="btn btn-ghost" @click="closeModal()">Hủy</button>
                            <button type="submit" class="btn btn-primary" :disabled="saving">
                                <span x-show="saving" class="loading loading-spinner loading-sm"></span>
                                <span x-show="!saving">
                                    <span x-show="!editingCompany">Thêm công ty</span>
                                    <span x-show="editingCompany">Cập nhật</span>
                                </span>
                            </button>
                        </div>
                    </form>
                </div>
                <div class="modal-backdrop" @click="closeModal()"></div>
            </div>

            <!-- Delete Confirmation Modal -->
            <div class="modal" :class="{ 'modal-open': showDeleteModal }">
                <div class="modal-box">
                    <h3 class="font-bold text-lg mb-4 text-error">Xác nhận xóa</h3>
                    <p class="mb-4">
                        Bạn có chắc chắn muốn xóa công ty <strong x-text="companyToDelete?.name"></strong>? 
                        Hành động này không thể hoàn tác.
                    </p>
                    <div class="modal-action">
                        <button class="btn btn-ghost" @click="showDeleteModal = false">Hủy</button>
                        <button class="btn btn-error" @click="confirmDelete()" :disabled="deleting">
                            <span x-show="deleting" class="loading loading-spinner loading-sm"></span>
                            <span x-show="!deleting">Xóa</span>
                        </button>
                    </div>
                </div>
                <div class="modal-backdrop" @click="showDeleteModal = false"></div>
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

        @raw
        <script>
            function companyManager() {
                return {
                    companies: {
                        content: [],
                        totalElements: 0,
                        totalPages: 0,
                        numberOfElements: 0,
                        first: true,
                        last: true
                    },
                    loading: false,
                    saving: false,
                    deleting: false,
                    currentPage: 0,
                    pageSize: 10,
                    searchQuery: '',
                    showModal: false,
                    showDeleteModal: false,
                    editingCompany: null,
                    companyToDelete: null,
                    formData: {
                        name: '',
                        address: '',
                        phone: '',
                        email: ''
                    },
                    errors: {},
                    notifications: [],

                    async loadCompanies() {
                        this.loading = true;
                        try {
                            const params = new URLSearchParams({
                                page: this.currentPage,
                                size: this.pageSize,
                                sort: 'id,asc'
                            });

                            const response = await fetch('/api/companies?' + params);
                            if (response.ok) {
                                this.companies = await response.json();
                            } else {
                                this.showNotification('error', 'Không thể tải danh sách công ty', 'alert-triangle');
                            }
                        } catch (error) {
                            this.showNotification('error', 'Lỗi kết nối: ' + error.message, 'alert-triangle');
                        } finally {
                            this.loading = false;
                            this.$nextTick(() => lucide.createIcons());
                        }
                    },

                    async searchCompanies() {
                        if (this.searchQuery.trim()) {
                            this.loading = true;
                            try {
                                const response = await fetch('/api/companies/name/' + encodeURIComponent(this.searchQuery.trim()));
                                if (response.ok) {
                                    const company = await response.json();
                                    this.companies = {
                                        content: [company],
                                        totalElements: 1,
                                        totalPages: 1,
                                        numberOfElements: 1,
                                        first: true,
                                        last: true
                                    };
                                } else if (response.status === 404) {
                                    this.companies = {
                                        content: [],
                                        totalElements: 0,
                                        totalPages: 0,
                                        numberOfElements: 0,
                                        first: true,
                                        last: true
                                    };
                                } else {
                                    this.showNotification('error', 'Không thể tìm kiếm công ty', 'alert-triangle');
                                }
                            } catch (error) {
                                this.showNotification('error', 'Lỗi tìm kiếm: ' + error.message, 'alert-triangle');
                            } finally {
                                this.loading = false;
                            }
                        } else {
                            this.currentPage = 0;
                            this.loadCompanies();
                        }
                    },

                    changePage(page) {
                        this.currentPage = page;
                        this.loadCompanies();
                    },

                    getVisiblePages() {
                        const total = this.companies.totalPages;
                        const current = this.currentPage;
                        const pages = [];
                        
                        let start = Math.max(0, current - 2);
                        let end = Math.min(total - 1, current + 2);
                        
                        for (let i = start; i <= end; i++) {
                            pages.push(i);
                        }
                        
                        return pages;
                    },

                    openAddModal() {
                        this.editingCompany = null;
                        this.formData = { name: '', address: '', phone: '', email: '' };
                        this.errors = {};
                        this.showModal = true;
                    },

                    editCompany(company) {
                        this.editingCompany = company;
                        this.formData = { 
                            name: company.name, 
                            address: company.address,
                            phone: company.phone,
                            email: company.email
                        };
                        this.errors = {};
                        this.showModal = true;
                    },

                    viewCompany(company) {
                        this.showNotification('info', 'Xem chi tiết công ty: ' + company.name, 'info');
                    },

                    closeModal() {
                        this.showModal = false;
                        this.editingCompany = null;
                        this.formData = { name: '', address: '', phone: '', email: '' };
                        this.errors = {};
                    },

                    async saveCompany() {
                        this.saving = true;
                        this.errors = {};

                        try {
                            const url = this.editingCompany ? 
                                '/api/companies/' + this.editingCompany.id : 
                                '/api/companies';
                            
                            const method = this.editingCompany ? 'PUT' : 'POST';

                            const response = await fetch(url, {
                                method: method,
                                headers: {
                                    'Content-Type': 'application/json',
                                },
                                body: JSON.stringify(this.formData)
                            });

                            if (response.ok) {
                                const savedCompany = await response.json();
                                this.closeModal();
                                this.loadCompanies();
                                
                                const action = this.editingCompany ? 'cập nhật' : 'thêm';
                                this.showNotification('success', `Đã ${action} công ty "${savedCompany.name}" thành công`, 'check-circle');
                            } else if (response.status === 400) {
                                const errorData = await response.json();
                                this.handleValidationErrors(errorData);
                            } else {
                                this.showNotification('error', 'Không thể lưu thông tin công ty', 'alert-triangle');
                            }
                        } catch (error) {
                            this.showNotification('error', 'Lỗi kết nối: ' + error.message, 'alert-triangle');
                        } finally {
                            this.saving = false;
                        }
                    },

                    deleteCompany(company) {
                        this.companyToDelete = company;
                        this.showDeleteModal = true;
                    },

                    async confirmDelete() {
                        this.deleting = true;
                        try {
                            const response = await fetch('/api/companies/' + this.companyToDelete.id, {
                                method: 'DELETE'
                            });

                            if (response.ok) {
                                this.showDeleteModal = false;
                                this.loadCompanies();
                                this.showNotification('success', `Đã xóa công ty "${this.companyToDelete.name}" thành công`, 'check-circle');
                            } else {
                                this.showNotification('error', 'Không thể xóa công ty', 'alert-triangle');
                            }
                        } catch (error) {
                            this.showNotification('error', 'Lỗi kết nối: ' + error.message, 'alert-triangle');
                        } finally {
                            this.deleting = false;
                            this.companyToDelete = null;
                        }
                    },

                    handleValidationErrors(errorData) {
                        if (errorData.errors) {
                            errorData.errors.forEach(error => {
                                this.errors[error.field] = error.defaultMessage;
                            });
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
        </script>
        @endraw
    `
) 