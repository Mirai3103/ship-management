@template.layout(
title = "Đánh giá tàu",
activePage = "reviews-ship",
content = @`
    <div x-data="reviewManager()" x-init="loadCompanies()" class="space-y-6">
        <!-- Header Section -->
        <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
            <div>
                <h1 class="text-2xl font-bold">Kiểm tra & Đánh giá tàu</h1>
                <p class="text-base-content/70">RIGHTSHIP INSPECTION & REVIEW</p>
            </div>
        </div>
        
        <!-- Company, Ship and Template Selection -->
        <div class="card bg-base-100 shadow-xl">
            <div class="card-body">
                <h3 class="font-semibold text-lg mb-4">Chọn công ty, tàu và template kiểm tra</h3>
                <div class="grid grid-cols-1 lg:grid-cols-5 gap-4">
                    <!-- Company Selection -->
                    <div class="form-control">
                        <label class="label">
                            <span class="label-text">Công ty <span class="text-error">*</span></span>
                        </label>
                        <select 
                            class="select select-bordered"
                            x-model="selectedCompanyId"
                            @change="loadShipsByCompany()"
                            required
                        >
                            <option value="">Chọn công ty</option>
                            <template x-for="company in companies" :key="company.id">
                                <option :value="company.id" x-text="company.name"></option>
                            </template>
                        </select>
                    </div>

                    <!-- Ship Selection -->
                    <div class="form-control">
                        <label class="label">
                            <span class="label-text">Tàu <span class="text-error">*</span></span>
                        </label>
                        <select 
                            class="select select-bordered"
                            x-model="selectedShipId"
                            :disabled="!selectedCompanyId || loadingShips"
                            @change="loadChecklistTemplates()"
                            required
                        >
                            <option value="">Chọn tàu</option>
                            <template x-for="ship in ships" :key="ship.id">
                                <option :value="ship.id" x-text="ship.name"></option>
                            </template>
                        </select>
                    </div>

                    <!-- Template Selection -->
                    <div class="form-control">
                        <label class="label">
                            <span class="label-text">Mục kiểm tra</span>
                        </label>
                        <select 
                            class="select select-bordered"
                            x-model="selectedTemplateId"
                            :disabled="!selectedShipId || loadingTemplates"
                        >
                            <option value="">Tất cả template</option>
                            <template x-for="template in checklistTemplates" :key="template.id">
                                <option :value="template.id" x-text="template.section"></option>
                            </template>
                        </select>
                    </div>

                    <!-- Load Button -->
                    <div class="form-control">
                        <label class="label">
                            <span class="label-text">&nbsp;</span>
                        </label>
                        <button 
                            class="btn btn-primary"
                            @click="loadReviews()"
                            :disabled="!selectedCompanyId || !selectedShipId || loading"
                        >
                            <span x-show="loading" class="loading loading-spinner loading-sm"></span>
                            <span x-show="!loading" class="flex items-center gap-2">
                                <i data-lucide="download" class="w-4 h-4"></i>
                                Tải bảng
                            </span>
                        </button>
                    </div>

                    <!-- Add Template Button -->
                    <div class="form-control">
                        <label class="label">
                            <span class="label-text">&nbsp;</span>
                        </label>
                        <button 
                            class="btn btn-success"
                            @click="openAddTemplateModal()"
                            :disabled="!selectedShipId"
                        >
                            <i data-lucide="plus" class="w-4 h-4"></i>
                            Thêm Template
                        </button>
                    </div>
                </div>

                <!-- Search Bar (only shown after loading) -->
                <div class="flex flex-col lg:flex-row gap-4 mt-4" x-show="showSearchBar">
                    <div class="flex-1">
                        <div class="form-control">
                            <div class="input-group">
                                <input
                                    type="text"
                                    placeholder="Tìm kiếm trong kết quả..."
                                    class="input input-bordered flex-1"
                                    x-model="searchQuery"
                                    @input.debounce.300ms="searchReviews()"
                                />
                                <button class="btn btn-square" @click="searchReviews()">
                                    <i data-lucide="search" class="w-4 h-4"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Reviews Table (only shown after loading) -->
        <div x-show="showSearchBar" class="card bg-base-100 shadow-xl">
            <div class="card-body">
                <div class="flex items-center justify-between mb-4">
                    <h2 class="card-title">
                        <i data-lucide="clipboard-check" class="w-5 h-5"></i>
                        Bảng đánh giá tàu
                        <span x-show="selectedShipName" class="text-sm text-base-content/70" x-text="'- ' + selectedShipName"></span>
                    </h2>
                    <div class="text-sm text-base-content/70">
                        <span x-text="displayedTemplates.length"></span> template, 
                        <span x-text="getTotalItems()"></span> mục kiểm tra
                    </div>
                </div>

                <!-- Loading State -->
                <div x-show="loading" class="flex justify-center py-8">
                    <span class="loading loading-spinner loading-lg"></span>
                </div>

                <!-- Empty State -->
                <div x-show="!loading && displayedTemplates.length === 0" class="text-center py-8">
                    <i data-lucide="clipboard" class="w-16 h-16 mx-auto text-base-content/30 mb-4"></i>
                    <h3 class="text-lg font-medium mb-2">Chưa có template kiểm tra nào</h3>
                    <p class="text-base-content/70 mb-4">Tạo template đầu tiên cho tàu này</p>
                    <button @click="openAddTemplateModal()" class="btn btn-primary">
                        <i data-lucide="plus" class="w-4 h-4"></i>
                        Thêm Mục Mới
                    </button>
                </div>

                <!-- Unified Templates and Items Table -->
                <div x-show="!loading && displayedTemplates.length > 0" class="overflow-x-auto">
                    <table class="table table-zebra w-full text-sm">
                        <thead>
                            <tr class="bg-base-100">
                                <th class="text-center w-16">STT</th>
                                <th class="min-w-48">Nội dung ra soát</th>
                                <th class="min-w-32">Hướng dẫn</th>
                                <th class="min-w-32">Tài liệu đính kèm</th>
                                <th class="min-w-32">Người phụ trách</th>
                                <th class="text-center w-24">Đánh giá</th>
                                <th class="min-w-32">Remark</th>
                                <th class="min-w-32">Người phụ trách từ Cty</th>
                                <th class="text-center w-24">Đánh giá từ Cty</th>
                                <th class="min-w-32">Remark từ Cty</th>
                                <th class="min-w-32">Note</th>
                            </tr>
                        </thead>
                      <template x-for="template in displayedTemplates" :key="template.id">
    <tbody>
        <!-- Template Header Row -->
        <tr class="bg-base-200 border-t-2 border-base-300">
            <td colspan="11" class="p-4">
                <div class="flex items-center justify-between">
                    <div class="flex items-center gap-4">
                        <h3 class="text-lg font-bold" x-text="template.section"></h3>
                        <span class="badge badge-outline" x-text="'Thứ tự: ' + template.orderNo"></span>
                        <span class="badge badge-info" x-text="getFakeItemCount(template.id) + ' mục'"></span>
                    </div>
                    <div class="flex items-center gap-2">
                        <button class="btn btn-ghost btn-sm tooltip" data-tip="Thêm chi tiết">
                            <i data-lucide="plus" class="w-4 h-4"></i>
                        </button>
                        <button @click="editTemplate(template)" class="btn btn-ghost btn-sm tooltip" data-tip="Chỉnh sửa mục">
                            <i data-lucide="edit" class="w-4 h-4"></i>
                        </button>
                        <button @click="deleteTemplate(template)" class="btn btn-ghost btn-sm text-error tooltip" data-tip="Xóa mục">
                            <i data-lucide="trash-2" class="w-4 h-4"></i>
                        </button>
                    </div>
                </div>
            </td>
        </tr>

        <!-- Template Items -->
        <template x-for="(item, index) in getFakeItems(template.id)" :key="template.id + '_' + index">
            <tr>
                <td class="text-center font-mono" x-text="String(index + 1).padStart(2, '0')"></td>
                <td class="max-w-xs">
                    <div class="font-medium" x-text="item.content"></div>
                    <div class="text-xs text-gray-500" x-text="item.description"></div>
                </td>
                <td class="max-w-xs">
                    <div class="text-xs" x-text="item.guidance"></div>
                </td>
                <td>
                    <div class="flex flex-col gap-1">
                        <template x-for="doc in item.documents" :key="doc">
                            <span class="badge badge-outline badge-xs" x-text="doc"></span>
                        </template>
                    </div>
                </td>
                <td>
                    <div class="flex items-center gap-2">
                        <div class="avatar">
                            <div class="w-6 h-6 rounded-full">
                                <img :src="item.inspector.avatar" :alt="item.inspector.name" />
                            </div>
                        </div>
                        <span class="text-xs" x-text="item.inspector.name"></span>
                    </div>
                </td>
                <td class="text-center">
                    <span class="badge"
                          :class="{
                              'badge-success': item.evaluation === 'YES',
                              'badge-warning': item.evaluation === 'NO',
                              'badge-neutral': item.evaluation === 'NA'
                          }"
                          x-text="item.evaluation">
                    </span>
                </td>
                <td class="max-w-xs">
                    <div class="text-xs" x-text="item.remark"></div>
                </td>
                <td>
                    <div class="flex items-center gap-2">
                        <div class="avatar">
                            <div class="w-6 h-6 rounded-full">
                                <img :src="item.companyInspector.avatar" :alt="item.companyInspector.name" />
                            </div>
                        </div>
                        <span class="text-xs" x-text="item.companyInspector.name"></span>
                    </div>
                </td>
                <td class="text-center">
                    <span class="badge"
                          :class="{
                              'badge-success': item.companyEvaluation === 'YES',
                              'badge-warning': item.companyEvaluation === 'NO',
                              'badge-neutral': item.companyEvaluation === 'NA'
                          }"
                          x-text="item.companyEvaluation">
                    </span>
                </td>
                <td class="max-w-xs">
                    <div class="text-xs" x-text="item.companyRemark"></div>
                </td>
                <td class="max-w-xs">
                    <div class="text-xs" x-text="item.note"></div>
                </td>
            </tr>
        </template>
    </tbody>
</template>

                    </table>
                </div>

                <!-- Summary Section -->
                <div x-show="!loading && displayedTemplates.length > 0" class="mt-6 grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div class="stat bg-success/10 rounded-lg">
                        <div class="stat-figure text-success">
                            <i data-lucide="check-circle" class="w-8 h-8"></i>
                        </div>
                        <div class="stat-title text-success">Đạt yêu cầu</div>
                        <div class="stat-value text-success" x-text="getSummary().yes"></div>
                        <div class="stat-desc">mục kiểm tra</div>
                    </div>
                    
                    <div class="stat bg-warning/10 rounded-lg">
                        <div class="stat-figure text-warning">
                            <i data-lucide="alert-circle" class="w-8 h-8"></i>
                        </div>
                        <div class="stat-title text-warning">Cần cải thiện</div>
                        <div class="stat-value text-warning" x-text="getSummary().no"></div>
                        <div class="stat-desc">mục kiểm tra</div>
                    </div>
                    
                    <div class="stat bg-neutral/10 rounded-lg">
                        <div class="stat-figure text-neutral">
                            <i data-lucide="minus-circle" class="w-8 h-8"></i>
                        </div>
                        <div class="stat-title text-neutral">Chưa đánh giá</div>
                        <div class="stat-value text-neutral" x-text="getSummary().na"></div>
                        <div class="stat-desc">mục kiểm tra</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Add/Edit Template Modal -->
        <div class="modal" :class="{ 'modal-open': showTemplateModal }">
            <div class="modal-box">
                <h3 class="font-bold text-lg mb-4">
                    <span x-show="!editingTemplate">Thêm Mục Mới</span>
                    <span x-show="editingTemplate">Chỉnh sửa Mục</span>
                </h3>
                
                <form @submit.prevent="saveTemplate()" class="space-y-4">
                    <!-- Section Name -->
                    <div class="form-control">
                        <label class="label">
                            <span class="label-text">Tên phần kiểm tra <span class="text-error">*</span></span>
                        </label>
                        <input 
                            type="text" 
                            placeholder="VD: Kiểm tra hệ thống an toàn" 
                            class="input input-bordered"
                            :class="{ 'input-error': templateErrors.section }"
                            x-model="templateForm.section"
                            required
                        />
                        <label class="label" x-show="templateErrors.section">
                            <span class="label-text-alt text-error" x-text="templateErrors.section"></span>
                        </label>
                    </div>

                    <!-- Order Number -->
                    <div class="form-control">
                        <label class="label">
                            <span class="label-text">Số thứ tự</span>
                        </label>
                        <input 
                            type="number" 
                            placeholder="0" 
                            class="input input-bordered"
                            :class="{ 'input-error': templateErrors.orderNo }"
                            x-model.number="templateForm.orderNo"
                            min="0"
                        />
                        <label class="label" x-show="templateErrors.orderNo">
                            <span class="label-text-alt text-error" x-text="templateErrors.orderNo"></span>
                        </label>
                    </div>

                    <div class="modal-action">
                        <button type="button" class="btn btn-ghost" @click="closeTemplateModal()">Hủy</button>
                        <button type="submit" class="btn btn-primary" :disabled="savingTemplate">
                            <span x-show="savingTemplate" class="loading loading-spinner loading-sm"></span>
                            <span x-show="!savingTemplate">
                                <span x-show="!editingTemplate">Thêm Template</span>
                                <span x-show="editingTemplate">Cập nhật</span>
                            </span>
                        </button>
                    </div>
                </form>
            </div>
            <div class="modal-backdrop" @click="closeTemplateModal()"></div>
        </div>

        <!-- Delete Template Confirmation Modal -->
        <div class="modal" :class="{ 'modal-open': showDeleteModal }">
            <div class="modal-box">
                <h3 class="font-bold text-lg mb-4 text-error">Xác nhận xóa</h3>
                <p class="mb-4">
                    Bạn có chắc chắn muốn xóa template <strong x-text="templateToDelete?.section"></strong>? 
                    Hành động này sẽ xóa tất cả checklist items bên trong và không thể hoàn tác.
                </p>
                <div class="modal-action">
                    <button class="btn btn-ghost" @click="showDeleteModal = false">Hủy</button>
                    <button class="btn btn-error" @click="confirmDeleteTemplate()" :disabled="deletingTemplate">
                        <span x-show="deletingTemplate" class="loading loading-spinner loading-sm"></span>
                        <span x-show="!deletingTemplate">Xóa</span>
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
        function reviewManager() {
            return {
                companies: [],
                ships: [],
                checklistTemplates: [],
                displayedTemplates: [],
                usersOfShip: [],
                selectedCompanyId: '',
                selectedShipId: '',
                selectedShipName: '',
                selectedTemplateId: '',
                searchQuery: '',
                showSearchBar: false,
                loading: false,
                loadingShips: false,
                loadingTemplates: false,
                
                // Template management
                showTemplateModal: false,
                showDeleteModal: false,
                editingTemplate: null,
                templateToDelete: null,
                savingTemplate: false,
                deletingTemplate: false,
                templateForm: {
                    section: '',
                    orderNo: 0
                },
                templateErrors: {},
                notifications: [],

                async loadCompanies() {
                    try {
                        const response = await fetch('/api/companies?page=0&size=1000');
                        if (response.ok) {
                            const data = await response.json();
                            this.companies = data.content || [];
                        }
                    } catch (error) {
                        console.error('Failed to load companies:', error);
                        this.showNotification('error', 'Không thể tải danh sách công ty', 'alert-triangle');
                    }
                },

                async loadShipsByCompany() {
                    if (!this.selectedCompanyId) {
                        this.ships = [];
                        this.selectedShipId = '';
                        this.selectedShipName = '';
                        this.checklistTemplates = [];
                        this.usersOfShip = [];
                        this.showSearchBar = false;
                        return;
                    }

                    this.loadingShips = true;
                    this.selectedShipId = '';
                    this.selectedShipName = '';
                    this.checklistTemplates = [];
                    this.usersOfShip = [];
                    this.showSearchBar = false;
                    
                    try {
                        const response = await fetch(`/api/ships?page=0&size=1000`);
                        if (response.ok) {
                            const data = await response.json();
                            // Note: Need to filter by company once company relationship is available in Ship entity
                            this.ships = data.content || [];
                        }
                    } catch (error) {
                        console.error('Failed to load ships:', error);
                        this.ships = [];
                        this.showNotification('error', 'Không thể tải danh sách tàu', 'alert-triangle');
                    } finally {
                        this.loadingShips = false;
                    }
                },

                async loadChecklistTemplates() {
                    if (!this.selectedShipId) {
                        this.checklistTemplates = [];
                        this.selectedTemplateId = '';
                        this.showSearchBar = false;
                        return;
                    }

                    this.loadingTemplates = true;
                    this.selectedTemplateId = '';
                    this.showSearchBar = false;

                    // Set selected ship name
                    const selectedShip = this.ships.find(ship => ship.id == this.selectedShipId);
                    this.selectedShipName = selectedShip ? selectedShip.name : '';
                    
                    try {
                        const response = await fetch(`/api/checklist-templates/ship/${this.selectedShipId}/ordered`);
                        if (response.ok) {
                            this.checklistTemplates = await response.json();
                            this.usersOfShip = await fetch(`/api/ships/${this.selectedShipId}/users`).then(res => res.json());

                            console.log('Loaded checklist templates:', this.checklistTemplates);
                        } else {
                            console.error('Failed to load templates, status:', response.status);
                            this.checklistTemplates = [];
                        }
                    } catch (error) {
                        console.error('Failed to load checklist templates:', error);
                        this.checklistTemplates = [];
                        this.showNotification('error', 'Không thể tải danh sách template', 'alert-triangle');
                    } finally {
                        this.loadingTemplates = false;
                    }
                },

                async loadReviews() {
                    if (!this.selectedCompanyId || !this.selectedShipId) {
                        console.log('Missing company or ship ID');
                        return;
                    }

                    this.loading = true;
                    console.log('Loading reviews for ship:', this.selectedShipId, 'Available templates:', this.checklistTemplates.length);
                    
                    try {
                        // Filter templates based on selection
                        if (this.selectedTemplateId) {
                            this.displayedTemplates = this.checklistTemplates.filter(
                                template => template.id == this.selectedTemplateId
                            );
                        } else {
                            this.displayedTemplates = [...this.checklistTemplates];
                        }
                        
                        console.log('Displayed templates:', this.displayedTemplates.length);
                        
                        // Show search bar after successful load
                        this.showSearchBar = true;
                        
                        if (this.displayedTemplates.length === 0) {
                            this.showNotification('info', 'Chưa có template nào cho tàu này. Hãy thêm template mới!', 'info');
                        } else {
                            this.showNotification('success', `Đã tải ${this.displayedTemplates.length} template thành công`, 'check-circle');
                        }
                    } catch (error) {
                        console.error('Failed to load reviews:', error);
                        this.showNotification('error', 'Không thể tải dữ liệu đánh giá', 'alert-triangle');
                    } finally {
                        this.loading = false;
                        this.$nextTick(() => lucide.createIcons());
                    }
                },

                searchReviews() {
                    if (!this.searchQuery.trim()) {
                        this.loadReviews();
                        return;
                    }

                    const query = this.searchQuery.toLowerCase();
                    this.displayedTemplates = this.checklistTemplates.filter(template =>
                        template.section.toLowerCase().includes(query)
                    );
                },

                // Template Management Functions
                openAddTemplateModal() {
                    this.editingTemplate = null;
                    this.templateForm = { section: '', orderNo: 0 };
                    this.templateErrors = {};
                    this.showTemplateModal = true;
                },

                editTemplate(template) {
                    this.editingTemplate = template;
                    this.templateForm = {
                        section: template.section,
                        orderNo: template.orderNo
                    };
                    this.templateErrors = {};
                    this.showTemplateModal = true;
                },

                closeTemplateModal() {
                    this.showTemplateModal = false;
                    this.editingTemplate = null;
                    this.templateForm = { section: '', orderNo: 0 };
                    this.templateErrors = {};
                },

                async saveTemplate() {
                    this.savingTemplate = true;
                    this.templateErrors = {};

                    const templateData = {
                        ...this.templateForm,
                        shipId: this.selectedShipId,
                        companyId: this.selectedCompanyId
                    };

                    try {
                        const url = this.editingTemplate ? 
                            `/api/checklist-templates/${this.editingTemplate.id}` : 
                            '/api/checklist-templates';
                        
                        const method = this.editingTemplate ? 'PUT' : 'POST';

                        const response = await fetch(url, {
                            method: method,
                            headers: {
                                'Content-Type': 'application/json',
                            },
                            body: JSON.stringify(templateData)
                        });

                        const data = await response.json();

                        if (response.ok) {
                            this.closeTemplateModal();
                            await this.loadChecklistTemplates();
                            if (this.showSearchBar) {
                                this.loadReviews();
                            }
                            
                            const action = this.editingTemplate ? 'cập nhật' : 'thêm';
                            this.showNotification('success', data.message || `Đã ${action} Mục thành công`, 'check-circle');
                        } else {
                            this.showNotification('error', data.message || 'Không thể lưu Mục', 'alert-triangle');
                        }
                    } catch (error) {
                        this.showNotification('error', 'Lỗi kết nối: ' + error.message, 'alert-triangle');
                    } finally {
                        this.savingTemplate = false;
                    }
                },

                deleteTemplate(template) {
                    this.templateToDelete = template;
                    this.showDeleteModal = true;
                },

                async confirmDeleteTemplate() {
                    this.deletingTemplate = true;
                    try {
                        const response = await fetch(`/api/checklist-templates/${this.templateToDelete.id}`, {
                            method: 'DELETE'
                        });

                        if (response.ok) {
                            this.showDeleteModal = false;
                            await this.loadChecklistTemplates();
                            if (this.showSearchBar) {
                                this.loadReviews();
                            }
                            this.showNotification('success', `Đã xóa template "${this.templateToDelete.section}" thành công`, 'check-circle');
                        } else {
                            const data = await response.json();
                            this.showNotification('error', data.message || 'Không thể xóa template', 'alert-triangle');
                        }
                    } catch (error) {
                        this.showNotification('error', 'Lỗi kết nối: ' + error.message, 'alert-triangle');
                    } finally {
                        this.deletingTemplate = false;
                        this.templateToDelete = null;
                    }
                },

                // Fake data generation for checklist items
                getFakeItems(templateId) {
                    const fakeData = [
                        {
                            content: "Kiểm tra giấy tờ tàu",
                            description: "Xác minh tính hợp lệ của các giấy tờ",
                            guidance: "Kiểm tra đăng ký tàu, giấy phép hoạt động, bảo hiểm",
                            documents: ["File_001.pdf", "Doc_checklist.xlsx"],
                            inspector: {
                                name: "Nguyễn Văn A",
                                avatar: "https://ui-avatars.com/api/?name=Nguyen+Van+A&background=0d9488&color=fff&size=32"
                            },
                            evaluation: "YES",
                            remark: "Tất cả giấy tờ đầy đủ và hợp lệ",
                            companyInspector: {
                                name: "Trần Thị B",
                                avatar: "https://ui-avatars.com/api/?name=Tran+Thi+B&background=dc2626&color=fff&size=32"
                            },
                            companyEvaluation: "YES",
                            companyRemark: "Đã xác nhận với bộ phận pháp lý",
                            note: "Cần cập nhật bảo hiểm trong 30 ngày"
                        },
                        {
                            content: "Kiểm tra an toàn thiết bị",
                            description: "Đánh giá tình trạng thiết bị an toàn",
                            guidance: "Kiểm tra áo phao, bè cứu sinh, hệ thống báo cháy",
                            documents: ["Safety_check.pdf"],
                            inspector: {
                                name: "Lê Văn C",
                                avatar: "https://ui-avatars.com/api/?name=Le+Van+C&background=059669&color=fff&size=32"
                            },
                            evaluation: "NO",
                            remark: "Một số áo phao cần thay thế",
                            companyInspector: {
                                name: "Phạm Văn D",
                                avatar: "https://ui-avatars.com/api/?name=Pham+Van+D&background=7c3aed&color=fff&size=32"
                            },
                            companyEvaluation: "NO",
                            companyRemark: "Đồng ý cần cải thiện thiết bị",
                            note: "Ưu tiên cao - cần xử lý ngay"
                        }
                    ];

                    // Return different number of items for different templates for variety
                    const itemCount = (templateId % 3) + 2; // 2-4 items per template
                    return fakeData.slice(0, itemCount);
                },

                getFakeItemCount(templateId) {
                    return this.getFakeItems(templateId).length;
                },

                getTotalItems() {
                    return this.displayedTemplates.reduce((total, template) => {
                        return total + this.getFakeItemCount(template.id);
                    }, 0);
                },

                getSummary() {
                    let yes = 0, no = 0, na = 0;
                    
                    this.displayedTemplates.forEach(template => {
                        const items = this.getFakeItems(template.id);
                        items.forEach(item => {
                            if (item.evaluation === 'YES') yes++;
                            else if (item.evaluation === 'NO') no++;
                            else na++;
                        });
                    });

                    return { yes, no, na };
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