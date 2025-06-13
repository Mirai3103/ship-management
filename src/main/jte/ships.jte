@template.layout(
    title = "Quản lý tàu",
    activePage = "ships",
    content = @`
        <div x-data="shipManager()" x-init="loadShips(); loadCompanies()" class="space-y-6">
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
                                    <th>Công ty</th>
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
                                            <span class="text-sm max-w-xs truncate" x-text="ship.description" :title="ship.description"></span>
                                        </td>
                                        <td>
                                            <div class="flex items-center space-x-1">
                                                <i data-lucide="building" class="w-3 h-3 text-base-content/50"></i>
                                                <span class="text-sm" x-text="ship.companyName || 'Chưa có'"></span>
                                            </div>
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
                                                <button @click="editShipMembers(ship)" class="btn btn-ghost btn-xs tooltip" data-tip="Quản lý thành viên">
                                                    <i data-lucide="users" class="w-3 h-3"></i>
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

                        <!-- Company Selection -->
                        <div class="form-control">
                            <label class="label">
                                <span class="label-text">Công ty</span>
                            </label>
                            <select 
                                class="select select-bordered"
                                :class="{ 'select-error': errors.companyId }"
                                x-model="formData.companyId"
                            >
                                <option value="">Chọn công ty (tùy chọn)</option>
                                <template x-for="company in availableCompanies" :key="company.id">
                                    <option :value="company.id" x-text="company.name"></option>
                                </template>
                            </select>
                            <label class="label" x-show="errors.companyId">
                                <span class="label-text-alt text-error" x-text="errors.companyId"></span>
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

            <!-- View Ship Detail Modal -->
            <div class="modal" :class="{ 'modal-open': showViewModal }">
                <div class="modal-box max-w-2xl">
                    <h3 class="font-bold text-lg mb-6">
                        <i data-lucide="ship" class="w-5 h-5 inline mr-2"></i>
                        Chi tiết tàu
                    </h3>
                    
                    <div x-show="loadingShipDetail" class="flex justify-center py-8">
                        <span class="loading loading-spinner loading-lg"></span>
                    </div>

                    <div x-show="!loadingShipDetail && viewingShip" class="space-y-6">
                        <!-- Ship Header -->
                        <div class="flex items-center space-x-4 p-4 bg-base-200 rounded-lg">
                            <div class="w-16 h-16 bg-primary/20 rounded-full flex items-center justify-center">
                                <i data-lucide="ship" class="w-8 h-8 text-primary"></i>
                            </div>
                            <div>
                                <h4 class="text-xl font-semibold" x-text="viewingShip?.name"></h4>
                                <p class="text-base-content/70" x-text="viewingShip?.description"></p>
                                <div class="flex items-center gap-2 mt-2">
                                    <span class="badge badge-success">Hoạt động</span>
                                    <span x-show="viewingShip?.companyName" class="badge badge-ghost">
                                        <i data-lucide="building" class="w-3 h-3 mr-1"></i>
                                        <span x-text="viewingShip?.companyName"></span>
                                    </span>
                                </div>
                            </div>
                        </div>

                        <!-- Detailed Information -->
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <!-- Ship ID -->
                            <div class="form-control">
                                <label class="label">
                                    <span class="label-text font-medium">ID tàu</span>
                                </label>
                                <div class="input input-bordered bg-base-200 flex items-center">
                                    <span class="font-mono" x-text="viewingShip?.id"></span>
                                </div>
                            </div>

                            <!-- Ship Name -->
                            <div class="form-control">
                                <label class="label">
                                    <span class="label-text font-medium">Tên tàu</span>
                                </label>
                                <div class="input input-bordered bg-base-200 flex items-center">
                                    <span x-text="viewingShip?.name"></span>
                                </div>
                            </div>

                            <!-- Description -->
                            <div class="form-control md:col-span-2">
                                <label class="label">
                                    <span class="label-text font-medium">Mô tả</span>
                                </label>
                                <div class="textarea textarea-bordered bg-base-200 min-h-[4rem] flex items-start p-3">
                                    <span x-text="viewingShip?.description"></span>
                                </div>
                            </div>

                            <!-- Company -->
                            <div class="form-control">
                                <label class="label">
                                    <span class="label-text font-medium">Công ty</span>
                                </label>
                                <div class="input input-bordered bg-base-200 flex items-center">
                                    <i data-lucide="building" class="w-4 h-4 mr-2 text-base-content/50"></i>
                                    <span x-text="viewingShip?.companyName || 'Chưa có'"></span>
                                </div>
                            </div>

                            <!-- Company ID -->
                            <div class="form-control" x-show="viewingShip?.companyId">
                                <label class="label">
                                    <span class="label-text font-medium">ID công ty</span>
                                </label>
                                <div class="input input-bordered bg-base-200 flex items-center">
                                    <span class="font-mono" x-text="viewingShip?.companyId"></span>
                                </div>
                            </div>
                        </div>

                        <!-- Additional Information -->
                        <div class="alert alert-info">
                            <i data-lucide="info" class="w-4 h-4"></i>
                            <div class="text-sm">
                                <strong>Lưu ý:</strong> Thông tin chi tiết này chỉ dành cho mục đích quản trị. 
                                Để thay đổi thông tin, vui lòng sử dụng chức năng "Chỉnh sửa".
                            </div>
                        </div>
                    </div>

                    <div class="modal-action">
                        <button class="btn btn-ghost" @click="closeViewModal()">Đóng</button>
                        <button class="btn btn-primary" @click="editShipFromView()" x-show="viewingShip">
                            <i data-lucide="edit" class="w-4 h-4"></i>
                            Chỉnh sửa
                        </button>
                    </div>
                </div>
                <div class="modal-backdrop" @click="closeViewModal()"></div>
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

            <!-- Edit Ship Members Modal -->
            <div class="modal" :class="{ 'modal-open': showMembersModal }">
                <div class="modal-box max-w-4xl">
                    <h3 class="font-bold text-lg mb-4">
                        <i data-lucide="users" class="w-5 h-5 inline mr-2"></i>
                        Quản lý thành viên tàu: <span x-text="editingMembersShip?.name"></span>
                    </h3>
                    
                    <div x-show="loadingMembers" class="flex justify-center py-8">
                        <span class="loading loading-spinner loading-lg"></span>
                    </div>

                    <div x-show="!loadingMembers" class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                        <!-- Available Users Section -->
                        <div class="space-y-4">
                            <h4 class="font-semibold text-base flex items-center">
                                <i data-lucide="user-plus" class="w-4 h-4 mr-2"></i>
                                Thêm thành viên
                            </h4>
                            
                            <!-- Company Filter Info -->
                            <div class="alert alert-info" x-show="editingMembersShip?.companyName">
                                <i data-lucide="info" class="w-4 h-4"></i>
                                <span class="text-sm">
                                    Hiển thị nhân viên từ công ty: <strong x-text="editingMembersShip?.companyName"></strong>
                                </span>
                            </div>
                            
                            <div class="alert alert-warning" x-show="!editingMembersShip?.companyId">
                                <i data-lucide="alert-triangle" class="w-4 h-4"></i>
                                <span class="text-sm">Tàu này chưa được gán cho công ty nào. Không thể thêm thành viên.</span>
                            </div>

                            <!-- Available Users List -->
                            <div x-show="editingMembersShip?.companyId" class="space-y-2 max-h-64 overflow-y-auto border rounded-lg p-3">
                                <template x-for="user in availableUsers" :key="user.id">
                                    <div class="flex items-center justify-between p-2 hover:bg-base-200 rounded">
                                        <div class="flex items-center space-x-3">
                                            <div class="w-8 h-8 bg-primary/20 rounded-full flex items-center justify-center">
                                                <i data-lucide="user" class="w-4 h-4 text-primary"></i>
                                            </div>
                                            <div>
                                                <p class="font-medium" x-text="user.fullName"></p>
                                                <p class="text-xs text-base-content/70" x-text="user.email"></p>
                                                <span class="badge badge-ghost badge-xs" x-text="user.roleName"></span>
                                            </div>
                                        </div>
                                        <button 
                                            @click="addUserToShip(user)" 
                                            class="btn btn-primary btn-xs"
                                            :disabled="savingMembers"
                                        >
                                            <i data-lucide="plus" class="w-3 h-3"></i>
                                        </button>
                                    </div>
                                </template>
                                <div x-show="availableUsers.length === 0" class="text-center py-4 text-base-content/70">
                                    <i data-lucide="users" class="w-8 h-8 mx-auto mb-2 opacity-50"></i>
                                    <p class="text-sm">Không có nhân viên khả dụng</p>
                                </div>
                            </div>
                        </div>

                        <!-- Current Members Section -->
                        <div class="space-y-4">
                            <h4 class="font-semibold text-base flex items-center">
                                <i data-lucide="users" class="w-4 h-4 mr-2"></i>
                                Thành viên hiện tại (<span x-text="currentMembers.length"></span>)
                            </h4>
                            
                            <!-- Current Members List -->
                            <div class="space-y-2 max-h-64 overflow-y-auto border rounded-lg p-3">
                                <template x-for="member in currentMembers" :key="member.id">
                                    <div class="flex items-center justify-between p-2 hover:bg-base-200 rounded">
                                        <div class="flex items-center space-x-3">
                                            <div class="w-8 h-8 bg-success/20 rounded-full flex items-center justify-center">
                                                <i data-lucide="user-check" class="w-4 h-4 text-success"></i>
                                            </div>
                                            <div>
                                                <p class="font-medium" x-text="member.fullName"></p>
                                                <p class="text-xs text-base-content/70" x-text="member.email"></p>
                                                <span class="badge badge-success badge-xs" x-text="member.roleName"></span>
                                            </div>
                                        </div>
                                        <button 
                                            @click="removeUserFromShip(member)" 
                                            class="btn btn-error btn-xs"
                                            :disabled="savingMembers"
                                        >
                                            <i data-lucide="minus" class="w-3 h-3"></i>
                                        </button>
                                    </div>
                                </template>
                                <div x-show="currentMembers.length === 0" class="text-center py-4 text-base-content/70">
                                    <i data-lucide="user-x" class="w-8 h-8 mx-auto mb-2 opacity-50"></i>
                                    <p class="text-sm">Chưa có thành viên nào</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="modal-action">
                        <button class="btn btn-ghost" @click="closeMembersModal()">Đóng</button>
                        <button 
                            class="btn btn-primary" 
                            @click="saveMemberChanges()"
                            :disabled="savingMembers || (usersToAdd.length === 0 && usersToRemove.length === 0)"
                        >
                            <span x-show="savingMembers" class="loading loading-spinner loading-sm"></span>
                            <span x-show="!savingMembers">
                                Lưu thay đổi 
                                <span x-show="usersToAdd.length > 0 || usersToRemove.length > 0" 
                                      class="badge badge-primary badge-sm ml-1">
                                    <span x-text="usersToAdd.length + usersToRemove.length"></span>
                                </span>
                            </span>
                        </button>
                    </div>
                </div>
                <div class="modal-backdrop" @click="closeMembersModal()"></div>
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
                    availableCompanies: [],
                    loading: false,
                    saving: false,
                    deleting: false,
                    loadingShipDetail: false,
                    loadingMembers: false,
                    savingMembers: false,
                    currentPage: 0,
                    pageSize: 10,
                    searchQuery: '',
                    showModal: false,
                    showDeleteModal: false,
                    showViewModal: false,
                    showMembersModal: false,
                    editingShip: null,
                    shipToDelete: null,
                    viewingShip: null,
                    editingMembersShip: null,
                    currentMembers: [],
                    availableUsers: [],
                    usersToAdd: [],
                    usersToRemove: [],
                    formData: {
                        name: '',
                        description: '',
                        companyId: ''
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

                    async loadCompanies() {
                        try {
                            const response = await fetch('/api/companies?page=0&size=1000');
                            if (response.ok) {
                                const companiesData = await response.json();
                                this.availableCompanies = companiesData.content || [];
                            }
                        } catch (error) {
                            console.error('Failed to load companies:', error);
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
                        this.formData = { name: '', description: '', companyId: '' };
                        this.errors = {};
                        this.showModal = true;
                    },

                    editShip(ship) {
                        this.editingShip = ship;
                        this.formData = { 
                            name: ship.name, 
                            description: ship.description,
                            companyId: ship.companyId || ''
                        };
                        this.errors = {};
                        this.showModal = true;
                    },

                    async viewShip(ship) {
                        this.loadingShipDetail = true;
                        this.showViewModal = true;
                        this.viewingShip = null;

                        try {
                            const response = await fetch('/api/ships/' + ship.id);
                            if (response.ok) {
                                this.viewingShip = await response.json();
                            } else {
                                this.showNotification('error', 'Không thể tải thông tin chi tiết tàu', 'alert-triangle');
                                this.closeViewModal();
                            }
                        } catch (error) {
                            this.showNotification('error', 'Lỗi kết nối: ' + error.message, 'alert-triangle');
                            this.closeViewModal();
                        } finally {
                            this.loadingShipDetail = false;
                            this.$nextTick(() => lucide.createIcons());
                        }
                    },

                    closeViewModal() {
                        this.showViewModal = false;
                        this.viewingShip = null;
                        this.loadingShipDetail = false;
                    },

                    editShipFromView() {
                        if (this.viewingShip) {
                            this.closeViewModal();
                            this.editShip(this.viewingShip);
                        }
                    },

                    closeModal() {
                        this.showModal = false;
                        this.editingShip = null;
                        this.formData = { name: '', description: '', companyId: '' };
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
                    },

                    async editShipMembers(ship) {
                        this.editingMembersShip = ship;
                        this.showMembersModal = true;
                        this.loadingMembers = true;
                        this.currentMembers = [];
                        this.availableUsers = [];
                        this.usersToAdd = [];
                        this.usersToRemove = [];

                        try {
                            // Load current ship members and available users from company in parallel
                            const [membersResponse, usersResponse] = await Promise.all([
                                fetch(`/api/ships/${ship.id}/users`),
                                ship.companyId ? fetch(`/api/users/company/${ship.companyId}`) : Promise.resolve({ ok: false })
                            ]);

                            if (membersResponse.ok) {
                                this.currentMembers = await membersResponse.json();
                            }

                            if (usersResponse.ok) {
                                const companyUsers = await usersResponse.json();
                                // Filter out users who are already members of this ship
                                const currentMemberIds = this.currentMembers.map(member => member.id);
                                this.availableUsers = companyUsers.filter(user => !currentMemberIds.includes(user.id));
                            }
                        } catch (error) {
                            this.showNotification('error', 'Lỗi khi tải danh sách thành viên: ' + error.message, 'alert-triangle');
                        } finally {
                            this.loadingMembers = false;
                            this.$nextTick(() => lucide.createIcons());
                        }
                    },

                    addUserToShip(user) {
                        // Remove from available users and add to pending additions
                        this.availableUsers = this.availableUsers.filter(u => u.id !== user.id);
                        
                        // If this user was previously marked for removal, just remove from removal list
                        const removeIndex = this.usersToRemove.findIndex(u => u.id === user.id);
                        if (removeIndex > -1) {
                            this.usersToRemove.splice(removeIndex, 1);
                            this.currentMembers.push(user);
                        } else {
                            // Add to current members and pending additions
                            this.currentMembers.push(user);
                            this.usersToAdd.push(user);
                        }
                    },

                    removeUserFromShip(user) {
                        // Remove from current members
                        this.currentMembers = this.currentMembers.filter(m => m.id !== user.id);
                        
                        // If this user was previously marked for addition, just remove from addition list
                        const addIndex = this.usersToAdd.findIndex(u => u.id === user.id);
                        if (addIndex > -1) {
                            this.usersToAdd.splice(addIndex, 1);
                        } else {
                            // Add to pending removals
                            this.usersToRemove.push(user);
                        }
                        
                        // Add back to available users if from same company
                        if (this.editingMembersShip.companyId && user.companyId === this.editingMembersShip.companyId) {
                            this.availableUsers.push(user);
                            // Sort available users by name
                            this.availableUsers.sort((a, b) => a.fullName.localeCompare(b.fullName));
                        }
                    },

                    async saveMemberChanges() {
                        if (this.usersToAdd.length === 0 && this.usersToRemove.length === 0) {
                            this.showNotification('warning', 'Không có thay đổi nào để lưu', 'info');
                            return;
                        }

                        this.savingMembers = true;
                        try {
                            const editData = {
                                shipId: this.editingMembersShip.id,
                                addUserIds: this.usersToAdd.map(user => user.id),
                                removeUserIds: this.usersToRemove.map(user => user.id)
                            };

                            const response = await fetch(`/api/ships/${this.editingMembersShip.id}/edit-users`, {
                                method: 'POST',
                                headers: {
                                    'Content-Type': 'application/json',
                                },
                                body: JSON.stringify(editData)
                            });

                            if (response.ok) {
                                this.closeMembersModal();
                                
                                const addedCount = this.usersToAdd.length;
                                const removedCount = this.usersToRemove.length;
                                let message = '';
                                
                                if (addedCount > 0 && removedCount > 0) {
                                    message = `Đã thêm ${addedCount} và xóa ${removedCount} thành viên khỏi tàu "${this.editingMembersShip.name}"`;
                                } else if (addedCount > 0) {
                                    message = `Đã thêm ${addedCount} thành viên vào tàu "${this.editingMembersShip.name}"`;
                                } else if (removedCount > 0) {
                                    message = `Đã xóa ${removedCount} thành viên khỏi tàu "${this.editingMembersShip.name}"`;
                                }
                                
                                this.showNotification('success', message, 'check-circle');
                            } else {
                                this.showNotification('error', 'Không thể cập nhật thành viên tàu', 'alert-triangle');
                            }
                        } catch (error) {
                            this.showNotification('error', 'Lỗi kết nối: ' + error.message, 'alert-triangle');
                        } finally {
                            this.savingMembers = false;
                        }
                    },

                    closeMembersModal() {
                        this.showMembersModal = false;
                        this.editingMembersShip = null;
                        this.currentMembers = [];
                        this.availableUsers = [];
                        this.usersToAdd = [];
                        this.usersToRemove = [];
                        this.loadingMembers = false;
                        this.savingMembers = false;
                    }
                }
            }
        </script>
        @endraw
    `
) 