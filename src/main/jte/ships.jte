@template.layout(
    title = "Quản lý tàu",
    activePage = "ships",
    content = @`
        <div x-data="shipManager()" x-init="loadShips()" class="space-y-6">
            <!-- Header Section -->
            <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
                <div>
                    <h1 class="text-2xl font-bold">Quản lý tàu</h1>
                    <p class="text-base-content/70">Quản lý thông tin và trạng thái các tàu trong đội</p>
                </div>
                <button @click="openAddModal()" class="btn btn-primary">
                    <i data-lucide="plus" class="w-4 h-4"></i>
                    Thêm tàu mới
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
                                        placeholder="Tìm kiếm theo tên tàu..." 
                                        class="input input-bordered flex-1"
                                        x-model="searchQuery"
                                        @input.debounce.300ms="searchShips()"
                                    />
                                    <button class="btn btn-square" @click="searchShips()">
                                        <i data-lucide="search" class="w-4 h-4"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Page Size Selector -->
                        <div class="form-control w-full max-w-xs">
                            <select class="select select-bordered" x-model="pageSize" @change="loadShips()">
                                <option value="5">5 tàu/trang</option>
                                <option value="10">10 tàu/trang</option>
                                <option value="20">20 tàu/trang</option>
                                <option value="50">50 tàu/trang</option>
                            </select>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Ships Table -->
            <div class="card bg-base-100 shadow-xl">
                <div class="card-body">
                    <div class="flex items-center justify-between mb-4">
                        <h2 class="card-title">
                            <i data-lucide="ship" class="w-5 h-5"></i>
                            Danh sách tàu
                        </h2>
                        <div class="text-sm text-base-content/70" x-show="ships.totalElements">
                            Hiển thị <span x-text="ships.numberOfElements"></span> trên <span x-text="ships.totalElements"></span> tàu
                        </div>
                    </div>

                    <!-- Loading State -->
                    <div x-show="loading" class="flex justify-center py-8">
                        <span class="loading loading-spinner loading-lg"></span>
                    </div>

                    <!-- Empty State -->
                    <div x-show="!loading && ships.content && ships.content.length === 0" class="text-center py-8">
                        <i data-lucide="ship" class="w-16 h-16 mx-auto text-base-content/30 mb-4"></i>
                        <h3 class="text-lg font-medium mb-2">Chưa có tàu nào</h3>
                        <p class="text-base-content/70 mb-4">Bắt đầu bằng cách thêm tàu đầu tiên của bạn</p>
                        <button @click="openAddModal()" class="btn btn-primary">
                            <i data-lucide="plus" class="w-4 h-4"></i>
                            Thêm tàu mới
                        </button>
                    </div>

                    <!-- Ships Table -->
                    <div x-show="!loading && ships.content && ships.content.length > 0" class="overflow-x-auto">
                        <table class="table table-zebra w-full">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Tên tàu</th>
                                    <th>Mô tả</th>
                                    <th>Trạng thái</th>
                                    <th>Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <template x-for="ship in ships.content" :key="ship.id">
                                    <tr>
                                        <td>
                                            <span class="font-mono text-sm" x-text="ship.id"></span>
                                        </td>
                                        <td>
                                            <div class="flex items-center space-x-3">
                                                <div class="w-3 h-3 bg-success rounded-full"></div>
                                                <span class="font-medium" x-text="ship.name"></span>
                                            </div>
                                        </td>
                                        <td>
                                            <span x-text="ship.description"></span>
                                        </td>
                                        <td>
                                            <span class="badge badge-success">Hoạt động</span>
                                        </td>
                                        <td>
                                            <div class="flex items-center space-x-2">
                                                <button @click="viewShip(ship)" class="btn btn-ghost btn-xs tooltip" data-tip="Xem chi tiết">
                                                    <i data-lucide="eye" class="w-3 h-3"></i>
                                                </button>
                                                <button @click="editShip(ship)" class="btn btn-ghost btn-xs tooltip" data-tip="Chỉnh sửa">
                                                    <i data-lucide="edit" class="w-3 h-3"></i>
                                                </button>
                                                <button @click="deleteShip(ship)" class="btn btn-ghost btn-xs text-error tooltip" data-tip="Xóa">
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
                    <div x-show="!loading && ships.totalPages > 1" class="flex justify-center mt-6">
                        <div class="join">
                            <button 
                                class="join-item btn" 
                                :disabled="ships.first"
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
                                :disabled="ships.last"
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
                        <span x-show="!editingShip">Thêm tàu mới</span>
                        <span x-show="editingShip">Chỉnh sửa tàu</span>
                    </h3>
                    
                    <form @submit.prevent="saveShip()" class="space-y-4">
                        <!-- Ship Name -->
                        <div class="form-control">
                            <label class="label">
                                <span class="label-text">Tên tàu <span class="text-error">*</span></span>
                            </label>
                            <input 
                                type="text" 
                                placeholder="Nhập tên tàu" 
                                class="input input-bordered"
                                :class="{ 'input-error': errors.name }"
                                x-model="formData.name"
                                required
                            />
                            <label class="label" x-show="errors.name">
                                <span class="label-text-alt text-error" x-text="errors.name"></span>
                            </label>
                        </div>

                        <!-- Ship Description -->
                        <div class="form-control">
                            <label class="label">
                                <span class="label-text">Mô tả <span class="text-error">*</span></span>
                            </label>
                            <textarea 
                                placeholder="Nhập mô tả tàu" 
                                class="textarea textarea-bordered h-24"
                                :class="{ 'textarea-error': errors.description }"
                                x-model="formData.description"
                                required
                            ></textarea>
                            <label class="label" x-show="errors.description">
                                <span class="label-text-alt text-error" x-text="errors.description"></span>
                            </label>
                        </div>

                        <div class="modal-action">
                            <button type="button" class="btn btn-ghost" @click="closeModal()">Hủy</button>
                            <button type="submit" class="btn btn-primary" :disabled="saving">
                                <span x-show="saving" class="loading loading-spinner loading-sm"></span>
                                <span x-show="!saving">
                                    <span x-show="!editingShip">Thêm tàu</span>
                                    <span x-show="editingShip">Cập nhật</span>
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
                        Bạn có chắc chắn muốn xóa tàu <strong x-text="shipToDelete?.name"></strong>? 
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
            function shipManager() {
                return {
                    ships: {
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
                    editingShip: null,
                    shipToDelete: null,
                    formData: {
                        name: '',
                        description: ''
                    },
                    errors: {},
                    notifications: [],

                    async loadShips() {
                        this.loading = true;
                        try {
                            const params = new URLSearchParams({
                                page: this.currentPage,
                                size: this.pageSize,
                                sort: 'id,asc'
                            });

                            const response = await fetch('/api/ships?' + params);
                            if (response.ok) {
                                this.ships = await response.json();
                            } else {
                                this.showNotification('error', 'Không thể tải danh sách tàu', 'alert-triangle');
                            }
                        } catch (error) {
                            this.showNotification('error', 'Lỗi kết nối: ' + error.message, 'alert-triangle');
                        } finally {
                            this.loading = false;
                            // Re-initialize Lucide icons after DOM update
                            this.$nextTick(() => lucide.createIcons());
                        }
                    },

                    async searchShips() {
                        if (this.searchQuery.trim()) {
                            this.loading = true;
                            try {
                                const response = await fetch('/api/ships/name/' + encodeURIComponent(this.searchQuery.trim()));
                                if (response.ok) {
                                    const ship = await response.json();
                                    this.ships = {
                                        content: [ship],
                                        totalElements: 1,
                                        totalPages: 1,
                                        numberOfElements: 1,
                                        first: true,
                                        last: true
                                    };
                                } else if (response.status === 404) {
                                    this.ships = {
                                        content: [],
                                        totalElements: 0,
                                        totalPages: 0,
                                        numberOfElements: 0,
                                        first: true,
                                        last: true
                                    };
                                } else {
                                    this.showNotification('error', 'Không thể tìm kiếm tàu', 'alert-triangle');
                                }
                            } catch (error) {
                                this.showNotification('error', 'Lỗi tìm kiếm: ' + error.message, 'alert-triangle');
                            } finally {
                                this.loading = false;
                            }
                        } else {
                            this.currentPage = 0;
                            this.loadShips();
                        }
                    },

                    changePage(page) {
                        this.currentPage = page;
                        this.loadShips();
                    },

                    getVisiblePages() {
                        const total = this.ships.totalPages;
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
                        this.editingShip = null;
                        this.formData = { name: '', description: '' };
                        this.errors = {};
                        this.showModal = true;
                    },

                    editShip(ship) {
                        this.editingShip = ship;
                        this.formData = { 
                            name: ship.name, 
                            description: ship.description 
                        };
                        this.errors = {};
                        this.showModal = true;
                    },

                    viewShip(ship) {
                        this.showNotification('info', 'Xem chi tiết tàu: ' + ship.name, 'info');
                    },

                    closeModal() {
                        this.showModal = false;
                        this.editingShip = null;
                        this.formData = { name: '', description: '' };
                        this.errors = {};
                    },

                    async saveShip() {
                        this.saving = true;
                        this.errors = {};

                        try {
                            const url = this.editingShip ? 
                                '/api/ships/' + this.editingShip.id : 
                                '/api/ships';
                            
                            const method = this.editingShip ? 'PUT' : 'POST';

                            const response = await fetch(url, {
                                method: method,
                                headers: {
                                    'Content-Type': 'application/json',
                                },
                                body: JSON.stringify(this.formData)
                            });

                            if (response.ok) {
                                const savedShip = await response.json();
                                this.closeModal();
                                this.loadShips();
                                
                                const action = this.editingShip ? 'cập nhật' : 'thêm';
                                this.showNotification('success', `Đã ${action} tàu "${savedShip.name}" thành công`, 'check-circle');
                            } else if (response.status === 400) {
                                const errorData = await response.json();
                                this.handleValidationErrors(errorData);
                            } else {
                                this.showNotification('error', 'Không thể lưu thông tin tàu', 'alert-triangle');
                            }
                        } catch (error) {
                            this.showNotification('error', 'Lỗi kết nối: ' + error.message, 'alert-triangle');
                        } finally {
                            this.saving = false;
                        }
                    },

                    deleteShip(ship) {
                        this.shipToDelete = ship;
                        this.showDeleteModal = true;
                    },

                    async confirmDelete() {
                        this.deleting = true;
                        try {
                            const response = await fetch('/api/ships/' + this.shipToDelete.id, {
                                method: 'DELETE'
                            });

                            if (response.ok) {
                                this.showDeleteModal = false;
                                this.loadShips();
                                this.showNotification('success', `Đã xóa tàu "${this.shipToDelete.name}" thành công`, 'check-circle');
                            } else {
                                this.showNotification('error', 'Không thể xóa tàu', 'alert-triangle');
                            }
                        } catch (error) {
                            this.showNotification('error', 'Lỗi kết nối: ' + error.message, 'alert-triangle');
                        } finally {
                            this.deleting = false;
                            this.shipToDelete = null;
                        }
                    },

                    handleValidationErrors(errorData) {
                        // Handle Spring Boot validation errors
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