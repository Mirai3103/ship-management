@template.layout(
    title = "Quản lý vai trò",
    activePage = "roles",
    content = @`
        <div x-data="roleManager()" x-init="loadRoles()" class="space-y-6">
            <!-- Header Section -->
            <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
                <div>
                    <h1 class="text-2xl font-bold">Quản lý vai trò</h1>
                    <p class="text-base-content/70">Quản lý các vai trò và quyền hạn trong hệ thống</p>
                </div>
                <button @click="openAddModal()" class="btn btn-primary">
                    <i data-lucide="plus" class="w-4 h-4"></i>
                    Thêm vai trò mới
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
                                        placeholder="Tìm kiếm theo tên vai trò..." 
                                        class="input input-bordered flex-1"
                                        x-model="searchQuery"
                                        @input.debounce.300ms="searchRoles()"
                                    />
                                    <button class="btn btn-square" @click="searchRoles()">
                                        <i data-lucide="search" class="w-4 h-4"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Page Size Selector -->
                        <div class="form-control w-full max-w-xs">
                            <select class="select select-bordered" x-model="pageSize" @change="loadRoles()">
                                <option value="5">5 vai trò/trang</option>
                                <option value="10">10 vai trò/trang</option>
                                <option value="20">20 vai trò/trang</option>
                                <option value="50">50 vai trò/trang</option>
                            </select>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Roles Table -->
            <div class="card bg-base-100 shadow-xl">
                <div class="card-body">
                    <div class="flex items-center justify-between mb-4">
                        <h2 class="card-title">
                            <i data-lucide="shield-check" class="w-5 h-5"></i>
                            Danh sách vai trò
                        </h2>
                        <div class="text-sm text-base-content/70" x-show="roles.totalElements">
                            Hiển thị <span x-text="roles.numberOfElements"></span> trên <span x-text="roles.totalElements"></span> vai trò
                        </div>
                    </div>

                    <!-- Loading State -->
                    <div x-show="loading" class="flex justify-center py-8">
                        <span class="loading loading-spinner loading-lg"></span>
                    </div>

                    <!-- Empty State -->
                    <div x-show="!loading && roles.content && roles.content.length === 0" class="text-center py-8">
                        <i data-lucide="shield-check" class="w-16 h-16 mx-auto text-base-content/30 mb-4"></i>
                        <h3 class="text-lg font-medium mb-2">Chưa có vai trò nào</h3>
                        <p class="text-base-content/70 mb-4">Bắt đầu bằng cách thêm vai trò đầu tiên</p>
                        <button @click="openAddModal()" class="btn btn-primary">
                            <i data-lucide="plus" class="w-4 h-4"></i>
                            Thêm vai trò mới
                        </button>
                    </div>

                    <!-- Roles Table -->
                    <div x-show="!loading && roles.content && roles.content.length > 0" class="overflow-x-auto">
                        <table class="table table-zebra w-full">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Tên vai trò</th>
                                    <th>Mô tả</th>
                                    <th>Loại vai trò</th>
                                    <th>Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <template x-for="role in roles.content" :key="role.id">
                                    <tr>
                                        <td>
                                            <span class="font-mono text-sm" x-text="role.id"></span>
                                        </td>
                                        <td>
                                            <div class="flex items-center space-x-3">
                                                <div class="w-3 h-3 bg-accent rounded-full"></div>
                                                <span class="font-medium badge badge-outline" x-text="role.name"></span>
                                            </div>
                                        </td>
                                        <td>
                                            <span x-text="role.description"></span>
                                        </td>
                                        <td>
                                            <span class="badge" 
                                                  :class="{
                                                      'badge-error': role.rootRole === 'ADMIN',
                                                      'badge-warning': role.rootRole === 'COMPANY', 
                                                      'badge-info': role.rootRole === 'SHIP'
                                                  }"
                                                  x-text="getRootRoleDisplay(role.rootRole)"></span>
                                        </td>
                                        <td>
                                            <div class="flex items-center space-x-2">
                                                <button @click="viewRole(role)" class="btn btn-ghost btn-xs tooltip" data-tip="Xem chi tiết">
                                                    <i data-lucide="eye" class="w-3 h-3"></i>
                                                </button>
                                                <button @click="editRole(role)" class="btn btn-ghost btn-xs tooltip" data-tip="Chỉnh sửa">
                                                    <i data-lucide="edit" class="w-3 h-3"></i>
                                                </button>
                                                <button @click="deleteRole(role)" class="btn btn-ghost btn-xs text-error tooltip" data-tip="Xóa" 
                                                        :disabled="role.name === 'ADMIN' || role.name === 'USER'">
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
                    <div x-show="!loading && roles.totalPages > 1" class="flex justify-center mt-6">
                        <div class="join">
                            <button 
                                class="join-item btn" 
                                :disabled="roles.first"
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
                                :disabled="roles.last"
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
                <div class="modal-box">
                    <h3 class="font-bold text-lg mb-4">
                        <span x-show="!editingRole">Thêm vai trò mới</span>
                        <span x-show="editingRole">Chỉnh sửa vai trò</span>
                    </h3>
                    
                    <form @submit.prevent="saveRole()" class="space-y-4">
                        <!-- Role Name -->
                        <div class="form-control">
                            <label class="label">
                                <span class="label-text">Tên vai trò <span class="text-error">*</span></span>
                            </label>
                            <input 
                                type="text" 
                                placeholder="Nhập tên vai trò (VD: MANAGER, OPERATOR)" 
                                class="input input-bordered"
                                :class="{ 'input-error': errors.name }"
                                x-model="formData.name"
                                required
                            />
                            <label class="label" x-show="errors.name">
                                <span class="label-text-alt text-error" x-text="errors.name"></span>
                            </label>
                        </div>

                        <!-- Role Description -->
                        <div class="form-control">
                            <label class="label">
                                <span class="label-text">Mô tả <span class="text-error">*</span></span>
                            </label>
                            <textarea 
                                placeholder="Nhập mô tả vai trò và quyền hạn" 
                                class="textarea textarea-bordered h-24"
                                :class="{ 'textarea-error': errors.description }"
                                x-model="formData.description"
                                required
                            ></textarea>
                            <label class="label" x-show="errors.description">
                                <span class="label-text-alt text-error" x-text="errors.description"></span>
                            </label>
                        </div>

                        <!-- Root Role Selection -->
                        <div class="form-control">
                            <label class="label">
                                <span class="label-text">Vai trò gốc <span class="text-error">*</span></span>
                            </label>
                            <select 
                                class="select select-bordered"
                                :class="{ 'select-error': errors.rootRole }"
                                x-model="formData.rootRole"
                                required
                            >
                                <option value="">Chọn vai trò gốc</option>
                                <option value="ADMIN">ADMIN - Quản trị viên</option>
                                <option value="COMPANY">COMPANY - Công ty</option>
                                <option value="SHIP">SHIP - Tàu thuyền</option>
                            </select>
                            <label class="label" x-show="errors.rootRole">
                                <span class="label-text-alt text-error" x-text="errors.rootRole"></span>
                            </label>
                        </div>

                        <!-- Role Guidelines -->
                        <div class="alert alert-info">
                            <i data-lucide="info" class="w-4 h-4"></i>
                            <div class="text-sm">
                                <strong>Lưu ý:</strong> Tên vai trò nên sử dụng chữ in hoa và không dấu (VD: ADMIN, USER, MANAGER)
                            </div>
                        </div>

                        <div class="modal-action">
                            <button type="button" class="btn btn-ghost" @click="closeModal()">Hủy</button>
                            <button type="submit" class="btn btn-primary" :disabled="saving">
                                <span x-show="saving" class="loading loading-spinner loading-sm"></span>
                                <span x-show="!saving">
                                    <span x-show="!editingRole">Thêm vai trò</span>
                                    <span x-show="editingRole">Cập nhật</span>
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
                        Bạn có chắc chắn muốn xóa vai trò <strong x-text="roleToDelete?.name"></strong>? 
                        Hành động này không thể hoàn tác và có thể ảnh hưởng đến các tài khoản người dùng.
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
            function roleManager() {
                return {
                    roles: {
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
                    editingRole: null,
                    roleToDelete: null,
                    formData: {
                        name: '',
                        description: '',
                        rootRole: ''
                    },
                    errors: {},
                    notifications: [],

                    async loadRoles() {
                        this.loading = true;
                        try {
                            const params = new URLSearchParams({
                                page: this.currentPage,
                                size: this.pageSize,
                                sort: 'id,asc'
                            });

                            const response = await fetch('/api/roles?' + params);
                            if (response.ok) {
                                this.roles = await response.json();
                            } else {
                                this.showNotification('error', 'Không thể tải danh sách vai trò', 'alert-triangle');
                            }
                        } catch (error) {
                            this.showNotification('error', 'Lỗi kết nối: ' + error.message, 'alert-triangle');
                        } finally {
                            this.loading = false;
                            this.$nextTick(() => lucide.createIcons());
                        }
                    },

                    async searchRoles() {
                        if (this.searchQuery.trim()) {
                            this.loading = true;
                            try {
                                const response = await fetch('/api/roles/name/' + encodeURIComponent(this.searchQuery.trim()));
                                if (response.ok) {
                                    const role = await response.json();
                                    this.roles = {
                                        content: [role],
                                        totalElements: 1,
                                        totalPages: 1,
                                        numberOfElements: 1,
                                        first: true,
                                        last: true
                                    };
                                } else if (response.status === 404) {
                                    this.roles = {
                                        content: [],
                                        totalElements: 0,
                                        totalPages: 0,
                                        numberOfElements: 0,
                                        first: true,
                                        last: true
                                    };
                                } else {
                                    this.showNotification('error', 'Không thể tìm kiếm vai trò', 'alert-triangle');
                                }
                            } catch (error) {
                                this.showNotification('error', 'Lỗi tìm kiếm: ' + error.message, 'alert-triangle');
                            } finally {
                                this.loading = false;
                            }
                        } else {
                            this.currentPage = 0;
                            this.loadRoles();
                        }
                    },

                    changePage(page) {
                        this.currentPage = page;
                        this.loadRoles();
                    },

                    getVisiblePages() {
                        const total = this.roles.totalPages;
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
                        this.editingRole = null;
                        this.formData = { name: '', description: '', rootRole: '' };
                        this.errors = {};
                        this.showModal = true;
                    },

                    editRole(role) {
                        this.editingRole = role;
                        this.formData = { 
                            name: role.name, 
                            description: role.description,
                            rootRole: role.rootRole
                        };
                        this.errors = {};
                        this.showModal = true;
                    },

                    viewRole(role) {
                        this.showNotification('info', 'Xem chi tiết vai trò: ' + role.name, 'info');
                    },

                    closeModal() {
                        this.showModal = false;
                        this.editingRole = null;
                        this.formData = { name: '', description: '', rootRole: '' };
                        this.errors = {};
                    },

                    async saveRole() {
                        this.saving = true;
                        this.errors = {};

                        try {
                            const url = this.editingRole ? 
                                '/api/roles/' + this.editingRole.id : 
                                '/api/roles';
                            
                            const method = this.editingRole ? 'PUT' : 'POST';

                            const response = await fetch(url, {
                                method: method,
                                headers: {
                                    'Content-Type': 'application/json',
                                },
                                body: JSON.stringify(this.formData)
                            });

                            const data = await response.json();

                            if (response.ok) {
                                this.closeModal();
                                this.loadRoles();
                                
                                const action = this.editingRole ? 'cập nhật' : 'thêm';
                                this.showNotification('success', `Đã ${action} vai trò "${data.name}" thành công`, 'check-circle');
                            } else {
                                this.showNotification('error', data.message || 'Không thể lưu thông tin vai trò', 'alert-triangle');
                            }
                        } catch (error) {
                            this.showNotification('error', 'Lỗi kết nối: ' + error.message, 'alert-triangle');
                        } finally {
                            this.saving = false;
                        }
                    },

                    deleteRole(role) {
                        this.roleToDelete = role;
                        this.showDeleteModal = true;
                    },

                    async confirmDelete() {
                        this.deleting = true;
                        try {
                            const response = await fetch('/api/roles/' + this.roleToDelete.id, {
                                method: 'DELETE'
                            });

                            if (response.ok) {
                                this.showDeleteModal = false;
                                this.loadRoles();
                                this.showNotification('success', `Đã xóa vai trò "${this.roleToDelete.name}" thành công`, 'check-circle');
                            } else {
                                const data = await response.json();
                                this.showNotification('error', data.message || 'Không thể xóa vai trò', 'alert-triangle');
                            }
                        } catch (error) {
                            this.showNotification('error', 'Lỗi kết nối: ' + error.message, 'alert-triangle');
                        } finally {
                            this.deleting = false;
                            this.roleToDelete = null;
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
                    },

                    getRootRoleDisplay(rootRole) {
                        switch (rootRole) {
                            case 'ADMIN':
                                return 'Quản trị viên';
                            case 'COMPANY':
                                return 'Công ty';
                            case 'SHIP':
                                return 'Tàu thuyền';
                            default:
                                return 'UNKNOWN';
                        }
                    }
                }
            }
        </script>
        @endraw
    `
) 