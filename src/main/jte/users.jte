@template.layout(
    title = "Quản lý người dùng",
    activePage = "users",
    content = @`
        <div x-data="userManager()" x-init="loadUsers(); loadRoles(); loadCompanies()" class="space-y-6">
            <!-- Header Section -->
            <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
                <div>
                    <h1 class="text-2xl font-bold">Quản lý người dùng</h1>
                    <p class="text-base-content/70">Quản lý tài khoản người dùng và phân quyền trong hệ thống</p>
                </div>
                <button @click="openAddModal()" class="btn btn-primary">
                    <i data-lucide="user-plus" class="w-4 h-4"></i>
                    Thêm người dùng mới
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
                                        placeholder="Tìm kiếm theo email..." 
                                        class="input input-bordered flex-1"
                                        x-model="searchQuery"
                                        @input.debounce.300ms="searchUsers()"
                                    />
                                    <button class="btn btn-square" @click="searchUsers()">
                                        <i data-lucide="search" class="w-4 h-4"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Page Size Selector -->
                        <div class="form-control w-full max-w-xs">
                            <select class="select select-bordered" x-model="pageSize" @change="loadUsers()">
                                <option value="5">5 người dùng/trang</option>
                                <option value="10">10 người dùng/trang</option>
                                <option value="20">20 người dùng/trang</option>
                                <option value="50">50 người dùng/trang</option>
                            </select>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Users Table -->
            <div class="card bg-base-100 shadow-xl">
                <div class="card-body min-h-[50vh]">
                    <div class="flex items-center justify-between mb-4">
                        <h2 class="card-title">
                            <i data-lucide="users" class="w-5 h-5"></i>
                            Danh sách người dùng
                        </h2>
                        <div class="text-sm text-base-content/70" x-show="users.totalElements">
                            Hiển thị <span x-text="users.numberOfElements"></span> trên <span x-text="users.totalElements"></span> người dùng
                        </div>
                    </div>

                    <!-- Loading State -->
                    <div x-show="loading" class="flex justify-center py-8">
                        <span class="loading loading-spinner loading-lg"></span>
                    </div>

                    <!-- Empty State -->
                    <div x-show="!loading && users.content && users.content.length === 0" class="text-center py-8">
                        <i data-lucide="users" class="w-16 h-16 mx-auto text-base-content/30 mb-4"></i>
                        <h3 class="text-lg font-medium mb-2">Chưa có người dùng nào</h3>
                        <p class="text-base-content/70 mb-4">Bắt đầu bằng cách thêm người dùng đầu tiên</p>
                        <button @click="openAddModal()" class="btn btn-primary">
                            <i data-lucide="user-plus" class="w-4 h-4"></i>
                            Thêm người dùng mới
                        </button>
                    </div>

                    <!-- Users Table -->
                    <div x-show="!loading && users.content && users.content.length > 0" class="overflow-x-auto h-full min-h-[50vh]">
                        <table class="table table-zebra w-full">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Họ và tên</th>
                                    <th>Email</th>
                                    <th>Vai trò</th>
                                    <th>Công ty</th>
                                    <th>Thao tác</th>
                                </tr>
                            </thead>
                            <tbody class="h-full">
                                <template x-for="user in users.content" :key="user.id">
                                    <tr>
                                        <td>
                                            <span class="font-mono text-sm" x-text="user.id"></span>
                                        </td>
                                        <td>
                                            <div class="flex items-center space-x-3">
                                                <div class="avatar">
                                                    <div class="w-8 h-8 rounded-full">
                                                        <img :src="'https://ui-avatars.com/api/?name=' + encodeURIComponent(user.fullName) + '&background=0d9488&color=fff'" :alt="user.fullName" />
                                                    </div>
                                                </div>
                                                <span class="font-medium" x-text="user.fullName"></span>
                                            </div>
                                        </td>
                                        <td>
                                            <span class="text-primary" x-text="user.email"></span>
                                        </td>
                                        <td>
                                            <span class="badge badge-outline" 
                                                  :class="{
                                                      'badge-error': user.roleName === 'ADMIN',
                                                      'badge-warning': user.roleName === 'MANAGER',
                                                      'badge-info': user.roleName === 'USER'
                                                  }"
                                                  x-text="user.roleName">
                                            </span>
                                        </td>
                                        <td>
                                            <div class="flex items-center space-x-1">
                                                <i data-lucide="building" class="w-3 h-3 text-base-content/50"></i>
                                                <span class="text-sm" x-text="user.companyName || 'Chưa có'"></span>
                                            </div>
                                        </td>
                                        <td>
                                            <div class="dropdown dropdown-end">
                                                <button tabindex="0" class="btn btn-ghost btn-xs">
                                                    <i data-lucide="more-horizontal" class="w-4 h-4"></i>
                                                </button>
                                                <ul tabindex="0" class="dropdown-content menu p-2 shadow bg-base-100 rounded-box w-52">
                                                    <li>
                                                        <a @click="viewUser(user)">
                                                            <i data-lucide="eye" class="w-4 h-4"></i>
                                                            Xem chi tiết
                                                        </a>
                                                    </li>
                                                    <li>
                                                        <a @click="editUser(user)">
                                                            <i data-lucide="edit" class="w-4 h-4"></i>
                                                            Chỉnh sửa
                                                        </a>
                                                    </li>
                                                    <li>
                                                        <a @click="openChangePasswordModal(user)">
                                                            <i data-lucide="key" class="w-4 h-4"></i>
                                                            Đổi mật khẩu
                                                        </a>
                                                    </li>
                                                    <li>
                                                        <a @click="openAssignRoleModal(user)">
                                                            <i data-lucide="shield" class="w-4 h-4"></i>
                                                            Gán vai trò
                                                        </a>
                                                    </li>
                                                    <li><hr></li>
                                                    <li>
                                                        <a @click="deleteUser(user)" class="text-error">
                                                            <i data-lucide="trash-2" class="w-4 h-4"></i>
                                                            Xóa
                                                        </a>
                                                    </li>
                                                </ul>
                                            </div>
                                        </td>
                                    </tr>
                                </template>
                            </tbody>
                        </table>
                    </div>

                    <!-- Pagination -->
                    <div x-show="!loading && users.totalPages > 1" class="flex justify-center mt-6">
                        <div class="join">
                            <button 
                                class="join-item btn" 
                                :disabled="users.first"
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
                                :disabled="users.last"
                                @click="changePage(currentPage + 1)"
                            >
                                <i data-lucide="chevron-right" class="w-4 h-4"></i>
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Add/Edit User Modal -->
            <div class="modal" :class="{ 'modal-open': showModal }">
                <div class="modal-box max-w-2xl">
                    <h3 class="font-bold text-lg mb-4">
                        <span x-show="!editingUser">Thêm người dùng mới</span>
                        <span x-show="editingUser">Chỉnh sửa người dùng</span>
                    </h3>
                    
                    <form @submit.prevent="saveUser()" class="space-y-4">
                        <!-- Full Name -->
                        <div class="form-control">
                            <label class="label">
                                <span class="label-text">Họ và tên <span class="text-error">*</span></span>
                            </label>
                            <input 
                                type="text" 
                                placeholder="Nhập họ và tên" 
                                class="input input-bordered"
                                :class="{ 'input-error': errors.fullName }"
                                x-model="formData.fullName"
                                required
                            />
                            <label class="label" x-show="errors.fullName">
                                <span class="label-text-alt text-error" x-text="errors.fullName"></span>
                            </label>
                        </div>

                        <!-- Email -->
                        <div class="form-control">
                            <label class="label">
                                <span class="label-text">Email <span class="text-error">*</span></span>
                            </label>
                            <input 
                                type="email" 
                                placeholder="user@example.com" 
                                class="input input-bordered"
                                :class="{ 'input-error': errors.email }"
                                x-model="formData.email"
                                required
                            />
                            <label class="label" x-show="errors.email">
                                <span class="label-text-alt text-error" x-text="errors.email"></span>
                            </label>
                        </div>

                        <!-- Role Selection -->
                        <div class="form-control">
                            <label class="label">
                                <span class="label-text">Vai trò <span class="text-error">*</span></span>
                            </label>
                            <select 
                                class="select select-bordered"
                                :class="{ 'select-error': errors.roleId }"
                                x-model="formData.roleId"
                                required
                            >
                                <option value="">Chọn vai trò</option>
                                <template x-for="role in availableRoles" :key="role.id">
                                    <option :value="role.id" x-text="role.name"></option>
                                </template>
                            </select>
                            <label class="label" x-show="errors.roleId">
                                <span class="label-text-alt text-error" x-text="errors.roleId"></span>
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

                        <!-- Default Password Notice -->
                        <div x-show="!editingUser" class="alert alert-info">
                            <i data-lucide="info" class="w-4 h-4"></i>
                            <div class="text-sm">
                                <strong>Lưu ý:</strong> Mật khẩu mặc định cho tài khoản mới là <strong>123456</strong>. 
                                Người dùng nên đổi mật khẩu sau lần đăng nhập đầu tiên.
                            </div>
                        </div>

                        <div class="modal-action">
                            <button type="button" class="btn btn-ghost" @click="closeModal()">Hủy</button>
                            <button type="submit" class="btn btn-primary" :disabled="saving">
                                <span x-show="saving" class="loading loading-spinner loading-sm"></span>
                                <span x-show="!saving">
                                    <span x-show="!editingUser">Thêm người dùng</span>
                                    <span x-show="editingUser">Cập nhật</span>
                                </span>
                            </button>
                        </div>
                    </form>
                </div>
                <div class="modal-backdrop" @click="closeModal()"></div>
            </div>

            <!-- Change Password Modal -->
            <div class="modal" :class="{ 'modal-open': showPasswordModal }">
                <div class="modal-box">
                    <h3 class="font-bold text-lg mb-4">Đổi mật khẩu</h3>
                    <p class="text-sm text-gray-600 mb-4">
                        Đổi mật khẩu cho: <strong x-text="userToChangePassword?.fullName"></strong>
                    </p>
                    
                    <form @submit.prevent="changePassword()" class="space-y-4">
                        <!-- Current Password -->
                        <div class="form-control">
                            <label class="label">
                                <span class="label-text">Mật khẩu hiện tại <span class="text-error">*</span></span>
                            </label>
                            <input 
                                type="password" 
                                placeholder="Nhập mật khẩu hiện tại" 
                                class="input input-bordered"
                                :class="{ 'input-error': passwordErrors.currentPassword }"
                                x-model="passwordForm.currentPassword"
                                required
                            />
                            <label class="label" x-show="passwordErrors.currentPassword">
                                <span class="label-text-alt text-error" x-text="passwordErrors.currentPassword"></span>
                            </label>
                        </div>

                        <!-- New Password -->
                        <div class="form-control">
                            <label class="label">
                                <span class="label-text">Mật khẩu mới <span class="text-error">*</span></span>
                            </label>
                            <input 
                                type="password" 
                                placeholder="Nhập mật khẩu mới" 
                                class="input input-bordered"
                                :class="{ 'input-error': passwordErrors.newPassword }"
                                x-model="passwordForm.newPassword"
                                required
                                minlength="6"
                            />
                            <label class="label" x-show="passwordErrors.newPassword">
                                <span class="label-text-alt text-error" x-text="passwordErrors.newPassword"></span>
                            </label>
                        </div>

                        <!-- Confirm New Password -->
                        <div class="form-control">
                            <label class="label">
                                <span class="label-text">Xác nhận mật khẩu mới <span class="text-error">*</span></span>
                            </label>
                            <input 
                                type="password" 
                                placeholder="Nhập lại mật khẩu mới" 
                                class="input input-bordered"
                                :class="{ 'input-error': passwordErrors.confirmNewPassword }"
                                x-model="passwordForm.confirmNewPassword"
                                required
                            />
                            <label class="label" x-show="passwordErrors.confirmNewPassword">
                                <span class="label-text-alt text-error" x-text="passwordErrors.confirmNewPassword"></span>
                            </label>
                        </div>

                        <div class="modal-action">
                            <button type="button" class="btn btn-ghost" @click="closePasswordModal()">Hủy</button>
                            <button type="submit" class="btn btn-primary" :disabled="changingPassword">
                                <span x-show="changingPassword" class="loading loading-spinner loading-sm"></span>
                                <span x-show="!changingPassword">Đổi mật khẩu</span>
                            </button>
                        </div>
                    </form>
                </div>
                <div class="modal-backdrop" @click="closePasswordModal()"></div>
            </div>

            <!-- Assign Role Modal -->
            <div class="modal" :class="{ 'modal-open': showRoleModal }">
                <div class="modal-box">
                    <h3 class="font-bold text-lg mb-4">Gán vai trò</h3>
                    <p class="text-sm text-gray-600 mb-4">
                        Gán vai trò cho: <strong x-text="userToAssignRole?.fullName"></strong>
                    </p>
                    <p class="text-sm text-gray-500 mb-4">
                        Vai trò hiện tại: <span class="badge badge-outline" x-text="userToAssignRole?.roleName"></span>
                    </p>
                    
                    <form @submit.prevent="assignRole()" class="space-y-4">
                        <!-- Role Selection -->
                        <div class="form-control">
                            <label class="label">
                                <span class="label-text">Chọn vai trò mới <span class="text-error">*</span></span>
                            </label>
                            <select 
                                class="select select-bordered"
                                x-model="roleForm.roleId"
                                required
                            >
                                <option value="">Chọn vai trò</option>
                                <template x-for="role in availableRoles" :key="role.id">
                                    <option :value="role.id" x-text="role.name + ' - ' + role.description"></option>
                                </template>
                            </select>
                        </div>

                        <div class="modal-action">
                            <button type="button" class="btn btn-ghost" @click="closeRoleModal()">Hủy</button>
                            <button type="submit" class="btn btn-primary" :disabled="assigningRole">
                                <span x-show="assigningRole" class="loading loading-spinner loading-sm"></span>
                                <span x-show="!assigningRole">Gán vai trò</span>
                            </button>
                        </div>
                    </form>
                </div>
                <div class="modal-backdrop" @click="closeRoleModal()"></div>
            </div>

            <!-- View User Detail Modal -->
            <div class="modal" :class="{ 'modal-open': showViewModal }">
                <div class="modal-box max-w-2xl">
                    <h3 class="font-bold text-lg mb-6">
                        <i data-lucide="user" class="w-5 h-5 inline mr-2"></i>
                        Chi tiết người dùng
                    </h3>
                    
                    <div x-show="loadingUserDetail" class="flex justify-center py-8">
                        <span class="loading loading-spinner loading-lg"></span>
                    </div>

                    <div x-show="!loadingUserDetail && viewingUser" class="space-y-6">
                        <!-- User Avatar and Basic Info -->
                        <div class="flex items-center space-x-4 p-4 bg-base-200 rounded-lg">
                            <div class="avatar">
                                <div class="w-16 h-16 rounded-full">
                                    <img :src="'https://ui-avatars.com/api/?name=' + encodeURIComponent(viewingUser?.fullName || '') + '&background=0d9488&color=fff&size=64'" 
                                         :alt="viewingUser?.fullName" />
                                </div>
                            </div>
                            <div>
                                <h4 class="text-xl font-semibold" x-text="viewingUser?.fullName"></h4>
                                <p class="text-base-content/70" x-text="viewingUser?.email"></p>
                                <div class="flex items-center gap-2 mt-2">
                                    <span class="badge badge-outline" 
                                          :class="{
                                              'badge-error': viewingUser?.roleName === 'ADMIN',
                                              'badge-warning': viewingUser?.roleName === 'MANAGER',
                                              'badge-info': viewingUser?.roleName === 'USER'
                                          }"
                                          x-text="viewingUser?.roleName">
                                    </span>
                                    <span x-show="viewingUser?.companyName" class="badge badge-ghost">
                                        <i data-lucide="building" class="w-3 h-3 mr-1"></i>
                                        <span x-text="viewingUser?.companyName"></span>
                                    </span>
                                </div>
                            </div>
                        </div>

                        <!-- Detailed Information -->
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <!-- User ID -->
                            <div class="form-control">
                                <label class="label">
                                    <span class="label-text font-medium">ID người dùng</span>
                                </label>
                                <div class="input input-bordered bg-base-200 flex items-center">
                                    <span class="font-mono" x-text="viewingUser?.id"></span>
                                </div>
                            </div>

                            <!-- Full Name -->
                            <div class="form-control">
                                <label class="label">
                                    <span class="label-text font-medium">Họ và tên</span>
                                </label>
                                <div class="input input-bordered bg-base-200 flex items-center">
                                    <span x-text="viewingUser?.fullName"></span>
                                </div>
                            </div>

                            <!-- Email -->
                            <div class="form-control md:col-span-2">
                                <label class="label">
                                    <span class="label-text font-medium">Địa chỉ email</span>
                                </label>
                                <div class="input input-bordered bg-base-200 flex items-center">
                                    <i data-lucide="mail" class="w-4 h-4 mr-2 text-base-content/50"></i>
                                    <span x-text="viewingUser?.email"></span>
                                </div>
                            </div>

                            <!-- Role -->
                            <div class="form-control">
                                <label class="label">
                                    <span class="label-text font-medium">Vai trò</span>
                                </label>
                                <div class="input input-bordered bg-base-200 flex items-center">
                                    <i data-lucide="shield" class="w-4 h-4 mr-2 text-base-content/50"></i>
                                    <span x-text="viewingUser?.roleName"></span>
                                </div>
                            </div>

                            <!-- Role ID -->
                            <div class="form-control">
                                <label class="label">
                                    <span class="label-text font-medium">ID vai trò</span>
                                </label>
                                <div class="input input-bordered bg-base-200 flex items-center">
                                    <span class="font-mono" x-text="viewingUser?.roleId"></span>
                                </div>
                            </div>

                            <!-- Company -->
                            <div class="form-control">
                                <label class="label">
                                    <span class="label-text font-medium">Công ty</span>
                                </label>
                                <div class="input input-bordered bg-base-200 flex items-center">
                                    <i data-lucide="building" class="w-4 h-4 mr-2 text-base-content/50"></i>
                                    <span x-text="viewingUser?.companyName || 'Chưa có'"></span>
                                </div>
                            </div>

                            <!-- Company ID -->
                            <div class="form-control" x-show="viewingUser?.companyId">
                                <label class="label">
                                    <span class="label-text font-medium">ID công ty</span>
                                </label>
                                <div class="input input-bordered bg-base-200 flex items-center">
                                    <span class="font-mono" x-text="viewingUser?.companyId"></span>
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
                        <button class="btn btn-primary" @click="editUserFromView()" x-show="viewingUser">
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
                        Bạn có chắc chắn muốn xóa người dùng <strong x-text="userToDelete?.fullName"></strong>? 
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
            function userManager() {
                return {
                    users: {
                        content: [],
                        totalElements: 0,
                        totalPages: 0,
                        numberOfElements: 0,
                        first: true,
                        last: true
                    },
                    availableRoles: [],
                    availableCompanies: [],
                    loading: false,
                    saving: false,
                    deleting: false,
                    changingPassword: false,
                    assigningRole: false,
                    currentPage: 0,
                    pageSize: 10,
                    searchQuery: '',
                    showModal: false,
                    showPasswordModal: false,
                    showRoleModal: false,
                    showDeleteModal: false,
                    showViewModal: false,
                    editingUser: null,
                    userToDelete: null,
                    userToChangePassword: null,
                    userToAssignRole: null,
                    viewingUser: null,
                    loadingUserDetail: false,
                    formData: {
                        fullName: '',
                        email: '',
                        roleId: '',
                        companyId: ''
                    },
                    passwordForm: {
                        currentPassword: '',
                        newPassword: '',
                        confirmNewPassword: ''
                    },
                    roleForm: {
                        roleId: ''
                    },
                    errors: {},
                    passwordErrors: {},
                    notifications: [],

                    async loadUsers() {
                        this.loading = true;
                        try {
                            const params = new URLSearchParams({
                                page: this.currentPage,
                                size: this.pageSize,
                                sort: 'id,asc'
                            });

                            const response = await fetch('/api/users?' + params);
                            if (response.ok) {
                                this.users = await response.json();
                            } else {
                                this.showNotification('error', 'Không thể tải danh sách người dùng', 'alert-triangle');
                            }
                        } catch (error) {
                            this.showNotification('error', 'Lỗi kết nối: ' + error.message, 'alert-triangle');
                        } finally {
                            this.loading = false;
                            this.$nextTick(() => lucide.createIcons());
                        }
                    },

                    async loadRoles() {
                        try {
                            const response = await fetch('/api/users/roles?page=0&size=1000');
                            if (response.ok) {
                                this.availableRoles = await response.json();
                            }
                        } catch (error) {
                            console.error('Failed to load roles:', error);
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

                    async searchUsers() {
                        if (this.searchQuery.trim()) {
                            this.loading = true;
                            try {
                                const response = await fetch('/api/users/email/' + encodeURIComponent(this.searchQuery.trim()));
                                if (response.ok) {
                                    const user = await response.json();
                                    this.users = {
                                        content: [user],
                                        totalElements: 1,
                                        totalPages: 1,
                                        numberOfElements: 1,
                                        first: true,
                                        last: true
                                    };
                                } else if (response.status === 404) {
                                    this.users = {
                                        content: [],
                                        totalElements: 0,
                                        totalPages: 0,
                                        numberOfElements: 0,
                                        first: true,
                                        last: true
                                    };
                                } else {
                                    this.showNotification('error', 'Không thể tìm kiếm người dùng', 'alert-triangle');
                                }
                            } catch (error) {
                                this.showNotification('error', 'Lỗi tìm kiếm: ' + error.message, 'alert-triangle');
                            } finally {
                                this.loading = false;
                            }
                        } else {
                            this.currentPage = 0;
                            this.loadUsers();
                        }
                    },

                    changePage(page) {
                        this.currentPage = page;
                        this.loadUsers();
                    },

                    getVisiblePages() {
                        const total = this.users.totalPages;
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
                        this.editingUser = null;
                        this.formData = { fullName: '', email: '', roleId: '', companyId: '' };
                        this.errors = {};
                        this.showModal = true;
                    },

                    editUser(user) {
                        this.editingUser = user;
                        this.formData = { 
                            fullName: user.fullName, 
                            email: user.email,
                            roleId: user.roleId,
                            companyId: user.companyId || ''
                        };
                        this.errors = {};
                        this.showModal = true;
                    },

                    async viewUser(user) {
                        this.loadingUserDetail = true;
                        this.showViewModal = true;
                        this.viewingUser = null;

                        try {
                            const response = await fetch('/api/users/' + user.id);
                            if (response.ok) {
                                this.viewingUser = await response.json();
                            } else {
                                this.showNotification('error', 'Không thể tải thông tin chi tiết người dùng', 'alert-triangle');
                                this.closeViewModal();
                            }
                        } catch (error) {
                            this.showNotification('error', 'Lỗi kết nối: ' + error.message, 'alert-triangle');
                            this.closeViewModal();
                        } finally {
                            this.loadingUserDetail = false;
                            this.$nextTick(() => lucide.createIcons());
                        }
                    },

                    closeViewModal() {
                        this.showViewModal = false;
                        this.viewingUser = null;
                        this.loadingUserDetail = false;
                    },

                    editUserFromView() {
                        if (this.viewingUser) {
                            this.closeViewModal();
                            this.editUser(this.viewingUser);
                        }
                    },

                    closeModal() {
                        this.showModal = false;
                        this.editingUser = null;
                        this.formData = { fullName: '', email: '', roleId: '', companyId: '' };
                        this.errors = {};
                    },

                    async saveUser() {
                        this.saving = true;
                        this.errors = {};

                        try {
                            const url = this.editingUser ? 
                                '/api/users/' + this.editingUser.id : 
                                '/api/users';
                            
                            const method = this.editingUser ? 'PUT' : 'POST';

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
                                this.loadUsers();
                                
                                const action = this.editingUser ? 'cập nhật' : 'thêm';
                                this.showNotification('success', data.message || `Đã ${action} người dùng thành công`, 'check-circle');
                            } else {
                                this.showNotification('error', data.message || 'Không thể lưu thông tin người dùng', 'alert-triangle');
                            }
                        } catch (error) {
                            this.showNotification('error', 'Lỗi kết nối: ' + error.message, 'alert-triangle');
                        } finally {
                            this.saving = false;
                        }
                    },

                    openChangePasswordModal(user) {
                        this.userToChangePassword = user;
                        this.passwordForm = { currentPassword: '', newPassword: '', confirmNewPassword: '' };
                        this.passwordErrors = {};
                        this.showPasswordModal = true;
                    },

                    closePasswordModal() {
                        this.showPasswordModal = false;
                        this.userToChangePassword = null;
                        this.passwordForm = { currentPassword: '', newPassword: '', confirmNewPassword: '' };
                        this.passwordErrors = {};
                    },

                    async changePassword() {
                        this.changingPassword = true;
                        this.passwordErrors = {};

                        // Client-side validation
                        if (this.passwordForm.newPassword !== this.passwordForm.confirmNewPassword) {
                            this.passwordErrors.confirmNewPassword = 'Mật khẩu xác nhận không khớp';
                            this.changingPassword = false;
                            return;
                        }

                        try {
                            const response = await fetch(`/api/users/${this.userToChangePassword.id}/change-password`, {
                                method: 'POST',
                                headers: {
                                    'Content-Type': 'application/json',
                                },
                                body: JSON.stringify(this.passwordForm)
                            });

                            const data = await response.json();

                            if (response.ok) {
                                this.closePasswordModal();
                                this.showNotification('success', data.message, 'check-circle');
                            } else {
                                this.showNotification('error', data.message, 'alert-triangle');
                            }
                        } catch (error) {
                            this.showNotification('error', 'Lỗi kết nối: ' + error.message, 'alert-triangle');
                        } finally {
                            this.changingPassword = false;
                        }
                    },

                    openAssignRoleModal(user) {
                        this.userToAssignRole = user;
                        this.roleForm = { roleId: user.roleId };
                        this.showRoleModal = true;
                    },

                    closeRoleModal() {
                        this.showRoleModal = false;
                        this.userToAssignRole = null;
                        this.roleForm = { roleId: '' };
                    },

                    async assignRole() {
                        this.assigningRole = true;

                        try {
                            const response = await fetch(`/api/users/${this.userToAssignRole.id}/assign-role`, {
                                method: 'POST',
                                headers: {
                                    'Content-Type': 'application/json',
                                },
                                body: JSON.stringify(this.roleForm)
                            });

                            const data = await response.json();

                            if (response.ok) {
                                this.closeRoleModal();
                                this.loadUsers(); // Reload to show updated role
                                this.showNotification('success', data.message, 'check-circle');
                            } else {
                                this.showNotification('error', data.message, 'alert-triangle');
                            }
                        } catch (error) {
                            this.showNotification('error', 'Lỗi kết nối: ' + error.message, 'alert-triangle');
                        } finally {
                            this.assigningRole = false;
                        }
                    },

                    deleteUser(user) {
                        this.userToDelete = user;
                        this.showDeleteModal = true;
                    },

                    async confirmDelete() {
                        this.deleting = true;
                        try {
                            const response = await fetch('/api/users/' + this.userToDelete.id, {
                                method: 'DELETE'
                            });

                            if (response.ok) {
                                this.showDeleteModal = false;
                                this.loadUsers();
                                this.showNotification('success', `Đã xóa người dùng "${this.userToDelete.fullName}" thành công`, 'check-circle');
                            } else {
                                this.showNotification('error', 'Không thể xóa người dùng', 'alert-triangle');
                            }
                        } catch (error) {
                            this.showNotification('error', 'Lỗi kết nối: ' + error.message, 'alert-triangle');
                        } finally {
                            this.deleting = false;
                            this.userToDelete = null;
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