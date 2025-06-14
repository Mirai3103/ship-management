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
                                <th class="text-center w-20">Thao tác</th>
                            </tr>
                        </thead>
                      <template x-for="template in displayedTemplates" :key="template.id">
    <tbody>
        <!-- Template Header Row -->
        <tr class="bg-base-200 border-t-2 border-base-300">
            <td colspan="12" class="p-4">
                <div class="flex items-center justify-between">
                    <div class="flex items-center gap-4">
                        <h3 class="text-lg font-bold" x-text="template.section"></h3>
                        <span class="badge badge-outline" x-text="'Thứ tự: ' + template.orderNo"></span>
                        <span class="badge badge-info" x-text="getItemCount(template) + ' mục'"></span>
                    </div>
                    <div class="flex items-center gap-2">
                        <button @click="openCreateItemModal(template)" class="btn btn-ghost btn-sm tooltip" data-tip="Thêm chi tiết">
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
        <template x-for="(item, index) in getItems(template)" :key="template.id + '_' + index">
            <tr>
                <td class="text-center font-mono" x-text="String(index + 1).padStart(2, '0')"></td>
                <td class="max-w-xs">
                    <div class="font-medium" x-text="item.content"></div>
                </td>
                <td class="max-w-xs">
                    <div class="text-xs" x-text="item.guide"></div>
                </td>
                <td>
                    <!-- Attachments placeholder - not implemented yet -->
                    <span class="text-xs text-gray-400">-</span>
                </td>
                <td>
                    <div class="flex items-center gap-2">
                        <div>
                            <div class="text-xs font-medium" x-text="item.assignedToFullName"></div>
                            <div class="text-xs text-gray-500" x-text="item.assignedToRoleName"></div>
                        </div>
                    </div>
                </td>
                <td class="text-center">
                    <span class="badge"
                          :class="{
                              'badge-success': item.vesselResult === 'YES',
                              'badge-warning': item.vesselResult === 'NO',
                              'badge-neutral': !item.vesselResult || item.vesselResult === 'NA'
                          }"
                          x-text="item.vesselResult || 'N/A'">
                    </span>
                </td>
                <td class="max-w-xs">
                    <div class="text-xs" x-text="item.vesselRemark || '-'"></div>
                </td>
                <td>
                    <div class="flex items-center gap-2">
                
                        <div>
                            <div class="text-xs font-medium" x-text="item.comAssignedToFullName"></div>
                            <div class="text-xs text-gray-500" x-text="item.comAssignedToRoleName"></div>
                        </div>
                    </div>
                </td>
                <td class="text-center">
                    <span class="badge"
                          :class="{
                              'badge-success': item.comResult === 'YES',
                              'badge-warning': item.comResult === 'NO',
                              'badge-neutral': !item.comResult || item.comResult === 'NA'
                          }"
                          x-text="item.comResult || 'N/A'">
                    </span>
                </td>
                <td class="max-w-xs">
                    <div class="text-xs" x-text="item.comRemark || '-'"></div>
                </td>
                <td class="max-w-xs">
                    <div class="text-xs" x-text="item.note || '-'"></div>
                </td>
                <td class="text-center">
                    <div class="flex items-center gap-1">
                        <button @click="editChecklistItem(item)" class="btn btn-ghost btn-xs tooltip" data-tip="Chỉnh sửa">
                            <i data-lucide="edit" class="w-3 h-3"></i>
                        </button>
                        <button @click="deleteChecklistItem(item)" class="btn btn-ghost btn-xs text-error tooltip" data-tip="Xóa">
                            <i data-lucide="trash-2" class="w-3 h-3"></i>
                        </button>
                    </div>
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

        <!-- Create Checklist Item Modal -->
        <div class="modal" :class="{ 'modal-open': showCreateItemModal }">
            <div class="modal-box max-w-2xl">
                <h3 class="font-bold text-lg mb-4">Thêm mục kiểm tra mới</h3>
                <p class="text-sm text-base-content/70 mb-4" x-show="selectedTemplate">
                    Template: <span class="font-medium" x-text="selectedTemplate?.section"></span>
                </p>
                
                <form @submit.prevent="saveChecklistItem()" class="space-y-4">
                    <!-- Content -->
                    <div class="form-control">
                        <label class="label">
                            <span class="label-text">Nội dung kiểm tra <span class="text-error">*</span></span>
                        </label>
                        <textarea 
                            placeholder="Mô tả chi tiết nội dung cần kiểm tra" 
                            class="textarea textarea-bordered h-20"
                            :class="{ 'textarea-error': itemErrors.content }"
                            x-model="itemForm.content"
                            required
                        ></textarea>
                        <label class="label" x-show="itemErrors.content">
                            <span class="label-text-alt text-error" x-text="itemErrors.content"></span>
                        </label>
                    </div>

                    <!-- Guide -->
                    <div class="form-control">
                        <label class="label">
                            <span class="label-text">Hướng dẫn</span>
                        </label>
                        <textarea 
                            placeholder="Hướng dẫn thực hiện kiểm tra" 
                            class="textarea textarea-bordered h-20"
                            :class="{ 'textarea-error': itemErrors.guide }"
                            x-model="itemForm.guide"
                        ></textarea>
                        <label class="label" x-show="itemErrors.guide">
                            <span class="label-text-alt text-error" x-text="itemErrors.guide"></span>
                        </label>
                    </div>

                    <!-- Order Number -->
                    <div class="form-control">
                        <label class="label">
                            <span class="label-text">Số thứ tự</span>
                        </label>
                        <input 
                            type="text" 
                            placeholder="VD: 1.1, 2.3, A.1" 
                            class="input input-bordered"
                            :class="{ 'input-error': itemErrors.orderNo }"
                            x-model="itemForm.orderNo"
                        />
                        <label class="label" x-show="itemErrors.orderNo">
                            <span class="label-text-alt text-error" x-text="itemErrors.orderNo"></span>
                        </label>
                    </div>

                    <!-- Assigned To (SHIP users) -->
                    <div class="form-control">
                        <label class="label">
                            <span class="label-text">Người phụ trách (Tàu) <span class="text-error">*</span></span>
                        </label>
                        <select 
                            class="select select-bordered"
                            :class="{ 'select-error': itemErrors.assignedToId }"
                            x-model="itemForm.assignedToId"
                            required
                        >
                            <option value="">Chọn người phụ trách</option>
                            <template x-for="user in getShipUsers()" :key="user.id">
                                <option :value="user.id" x-text="user.fullName + ' (' + user.roleName + ')'"></option>
                            </template>
                        </select>
                        <label class="label" x-show="itemErrors.assignedToId">
                            <span class="label-text-alt text-error" x-text="itemErrors.assignedToId"></span>
                        </label>
                    </div>

                    <!-- Company Assigned To (COMPANY users) -->
                    <div class="form-control">
                        <label class="label">
                            <span class="label-text">Người phụ trách (Công ty) <span class="text-error">*</span></span>
                        </label>
                        <select 
                            class="select select-bordered"
                            :class="{ 'select-error': itemErrors.comAssignedToId }"
                            x-model="itemForm.comAssignedToId"
                            required
                        >
                            <option value="">Chọn người phụ trách</option>
                            <template x-for="user in getCompanyUsers()" :key="user.id">
                                <option :value="user.id" x-text="user.fullName + ' (' + user.roleName + ')'"></option>
                            </template>
                        </select>
                        <label class="label" x-show="itemErrors.comAssignedToId">
                            <span class="label-text-alt text-error" x-text="itemErrors.comAssignedToId"></span>
                        </label>
                    </div>

                    <div class="modal-action">
                        <button type="button" class="btn btn-ghost" @click="closeCreateItemModal()">Hủy</button>
                        <button type="submit" class="btn btn-primary" :disabled="savingItem">
                            <span x-show="savingItem" class="loading loading-spinner loading-sm"></span>
                            <span x-show="!savingItem">Thêm mục kiểm tra</span>
                        </button>
                    </div>
                </form>
            </div>
            <div class="modal-backdrop" @click="closeCreateItemModal()"></div>
        </div>

        <!-- Edit Checklist Item Modal -->
        <div class="modal" :class="{ 'modal-open': showEditItemModal }">
            <div class="modal-box max-w-2xl">
                <h3 class="font-bold text-lg mb-4">Chỉnh sửa mục kiểm tra</h3>
                <p class="text-sm text-base-content/70 mb-4" x-show="editingItem">
                    Mục: <span class="font-medium" x-text="editingItem?.content"></span>
                </p>
                
                <form @submit.prevent="saveEditChecklistItem()" class="space-y-4">
                    <!-- Content -->
                    <div class="form-control">
                        <label class="label">
                            <span class="label-text">Nội dung kiểm tra <span class="text-error">*</span></span>
                        </label>
                        <textarea 
                            placeholder="Mô tả chi tiết nội dung cần kiểm tra" 
                            class="textarea textarea-bordered h-20"
                            :class="{ 'textarea-error': editItemErrors.content }"
                            x-model="editItemForm.content"
                            required
                        ></textarea>
                        <label class="label" x-show="editItemErrors.content">
                            <span class="label-text-alt text-error" x-text="editItemErrors.content"></span>
                        </label>
                    </div>

                    <!-- Guide -->
                    <div class="form-control">
                        <label class="label">
                            <span class="label-text">Hướng dẫn</span>
                        </label>
                        <textarea 
                            placeholder="Hướng dẫn thực hiện kiểm tra" 
                            class="textarea textarea-bordered h-20"
                            :class="{ 'textarea-error': editItemErrors.guide }"
                            x-model="editItemForm.guide"
                        ></textarea>
                        <label class="label" x-show="editItemErrors.guide">
                            <span class="label-text-alt text-error" x-text="editItemErrors.guide"></span>
                        </label>
                    </div>

                    <!-- Order Number -->
                    <div class="form-control">
                        <label class="label">
                            <span class="label-text">Số thứ tự</span>
                        </label>
                        <input 
                            type="text" 
                            placeholder="VD: 1.1, 2.3, A.1" 
                            class="input input-bordered"
                            :class="{ 'input-error': editItemErrors.orderNo }"
                            x-model="editItemForm.orderNo"
                        />
                        <label class="label" x-show="editItemErrors.orderNo">
                            <span class="label-text-alt text-error" x-text="editItemErrors.orderNo"></span>
                        </label>
                    </div>

                    <!-- Assigned To (SHIP users) -->
                    <div class="form-control">
                        <label class="label">
                            <span class="label-text">Người phụ trách (Tàu) <span class="text-error">*</span></span>
                        </label>
                        <select 
                            class="select select-bordered"
                            :class="{ 'select-error': editItemErrors.assignedToId }"
                            x-model="editItemForm.assignedToId"
                            required
                        >
                            <option value="">Chọn người phụ trách</option>
                            <template x-for="user in getShipUsers()" :key="user.id">
                                <option :value="user.id" x-text="user.fullName + ' (' + user.roleName + ')'"></option>
                            </template>
                        </select>
                        <label class="label" x-show="editItemErrors.assignedToId">
                            <span class="label-text-alt text-error" x-text="editItemErrors.assignedToId"></span>
                        </label>
                    </div>

                    <!-- Company Assigned To (COMPANY users) -->
                    <div class="form-control">
                        <label class="label">
                            <span class="label-text">Người phụ trách (Công ty) <span class="text-error">*</span></span>
                        </label>
                        <select 
                            class="select select-bordered"
                            :class="{ 'select-error': editItemErrors.comAssignedToId }"
                            x-model="editItemForm.comAssignedToId"
                            required
                        >
                            <option value="">Chọn người phụ trách</option>
                            <template x-for="user in getCompanyUsers()" :key="user.id">
                                <option :value="user.id" x-text="user.fullName + ' (' + user.roleName + ')'"></option>
                            </template>
                        </select>
                        <label class="label" x-show="editItemErrors.comAssignedToId">
                            <span class="label-text-alt text-error" x-text="editItemErrors.comAssignedToId"></span>
                        </label>
                    </div>

                    <div class="modal-action">
                        <button type="button" class="btn btn-ghost" @click="closeEditItemModal()">Hủy</button>
                        <button type="submit" class="btn btn-primary" :disabled="savingEditItem">
                            <span x-show="savingEditItem" class="loading loading-spinner loading-sm"></span>
                            <span x-show="!savingEditItem">Cập nhật</span>
                        </button>
                    </div>
                </form>
            </div>
            <div class="modal-backdrop" @click="closeEditItemModal()"></div>
        </div>

        <!-- Delete Checklist Item Confirmation Modal -->
        <div class="modal" :class="{ 'modal-open': showDeleteItemModal }">
            <div class="modal-box">
                <h3 class="font-bold text-lg mb-4 text-error">Xác nhận xóa</h3>
                <p class="mb-4">
                    Bạn có chắc chắn muốn xóa mục kiểm tra này không? 
                    <br><strong x-text="itemToDelete?.content"></strong>
                    <br>Hành động này không thể hoàn tác.
                </p>
                <div class="modal-action">
                    <button class="btn btn-ghost" @click="showDeleteItemModal = false">Hủy</button>
                    <button class="btn btn-error" @click="confirmDeleteChecklistItem()" :disabled="deletingItem">
                        <span x-show="deletingItem" class="loading loading-spinner loading-sm"></span>
                        <span x-show="!deletingItem">Xóa</span>
                    </button>
                </div>
            </div>
            <div class="modal-backdrop" @click="showDeleteItemModal = false"></div>
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

                // Checklist Item management
                showCreateItemModal: false,
                selectedTemplate: null,
                savingItem: false,
                itemForm: {
                    content: '',
                    guide: '',
                    orderNo: '',
                    assignedToId: '',
                    comAssignedToId: ''
                },
                itemErrors: {},

                // Edit/Delete Checklist Item management
                showEditItemModal: false,
                showDeleteItemModal: false,
                editingItem: null,
                itemToDelete: null,
                savingEditItem: false,
                deletingItem: false,
                editItemForm: {
                    content: '',
                    guide: '',
                    orderNo: '',
                    assignedToId: '',
                    comAssignedToId: ''
                },
                editItemErrors: {},

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

                // Get checklist items from template
                getItems(template) {
                    return template.checklistItems || [];
                },

                getItemCount(template) {
                    return template.checklistItems ? template.checklistItems.length : 0;
                },

                getTotalItems() {
                    return this.displayedTemplates.reduce((total, template) => {
                        return total + this.getItemCount(template);
                    }, 0);
                },

                getSummary() {
                    let yes = 0, no = 0, na = 0;
                    
                    this.displayedTemplates.forEach(template => {
                        const items = this.getItems(template);
                        items.forEach(item => {
                            if (item.vesselResult === 'YES') yes++;
                            else if (item.vesselResult === 'NO') no++;
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
                },

                // Checklist Item Functions
                openCreateItemModal(template) {
                    this.selectedTemplate = template;
                    this.itemForm = {
                        content: '',
                        guide: '',
                        orderNo: '',
                        assignedToId: '',
                        comAssignedToId: ''
                    };
                    this.itemErrors = {};
                    this.showCreateItemModal = true;
                },

                closeCreateItemModal() {
                    this.showCreateItemModal = false;
                    this.selectedTemplate = null;
                    this.itemForm = {
                        content: '',
                        guide: '',
                        orderNo: '',
                        assignedToId: '',
                        comAssignedToId: ''
                    };
                    this.itemErrors = {};
                },

                async saveChecklistItem() {
                    this.savingItem = true;
                    this.itemErrors = {};

                    const itemData = {
                        ...this.itemForm,
                        checklistTemplateId: this.selectedTemplate.id
                    };

                    try {
                        const response = await fetch('/api/checklist-items', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/json',
                            },
                            body: JSON.stringify(itemData)
                        });

                        const data = await response.json();

                        if (response.ok) {
                            this.closeCreateItemModal();
                            this.showNotification('success', 'Đã thêm mục kiểm tra thành công', 'check-circle');
                            // Optionally reload the reviews to show the new item
                            if (this.showSearchBar) {
                                this.loadReviews();
                            }
                        } else {
                            // Handle validation errors
                            if (data.errors) {
                                this.itemErrors = data.errors;
                            } else {
                                this.showNotification('error', data.message || 'Không thể thêm mục kiểm tra', 'alert-triangle');
                            }
                        }
                    } catch (error) {
                        this.showNotification('error', 'Lỗi kết nối: ' + error.message, 'alert-triangle');
                    } finally {
                        this.savingItem = false;
                    }
                },

                getShipUsers() {
                    return this.usersOfShip.filter(user => user.roleRootRole === 'SHIP');
                },

                getCompanyUsers() {
                    return this.usersOfShip.filter(user => user.roleRootRole === 'COMPANY');
                },

                // Edit Checklist Item Functions
                editChecklistItem(item) {
                    this.editingItem = item;
                    this.editItemForm = {
                        content: item.content || '',
                        guide: item.guide || '',
                        orderNo: item.orderNo || '',
                        assignedToId: item.assignedToId || '',
                        comAssignedToId: item.comAssignedToId || ''
                    };
                    this.editItemErrors = {};
                    this.showEditItemModal = true;
                },

                closeEditItemModal() {
                    this.showEditItemModal = false;
                    this.editingItem = null;
                    this.editItemForm = {
                        content: '',
                        guide: '',
                        orderNo: '',
                        assignedToId: '',
                        comAssignedToId: ''
                    };
                    this.editItemErrors = {};
                },

                async saveEditChecklistItem() {
                    this.savingEditItem = true;
                    this.editItemErrors = {};

                    try {
                        const response = await fetch(`/api/checklist-items/${this.editingItem.id}`, {
                            method: 'PATCH',
                            headers: {
                                'Content-Type': 'application/json',
                            },
                            body: JSON.stringify(this.editItemForm)
                        });

                        const data = await response.json();

                        if (response.ok) {
                            this.closeEditItemModal();
                            this.showNotification('success', 'Đã cập nhật mục kiểm tra thành công', 'check-circle');
                            // Reload checklist templates to get updated data
                            await this.loadChecklistTemplates();
                            if (this.showSearchBar) {
                                this.loadReviews();
                            }
                        } else {
                            // Handle validation errors
                            if (data.errors) {
                                this.editItemErrors = data.errors;
                            } else {
                                this.showNotification('error', data.message || 'Không thể cập nhật mục kiểm tra', 'alert-triangle');
                            }
                        }
                    } catch (error) {
                        this.showNotification('error', 'Lỗi kết nối: ' + error.message, 'alert-triangle');
                    } finally {
                        this.savingEditItem = false;
                    }
                },

                // Delete Checklist Item Functions
                deleteChecklistItem(item) {
                    this.itemToDelete = item;
                    this.showDeleteItemModal = true;
                },

                async confirmDeleteChecklistItem() {
                    this.deletingItem = true;
                    try {
                        const response = await fetch(`/api/checklist-items/${this.itemToDelete.id}`, {
                            method: 'DELETE'
                        });

                        if (response.ok) {
                            this.showDeleteItemModal = false;
                            this.showNotification('success', 'Đã xóa mục kiểm tra thành công', 'check-circle');
                            // Reload checklist templates to get updated data
                            await this.loadChecklistTemplates();
                            if (this.showSearchBar) {
                                this.loadReviews();
                            }
                        } else {
                            const data = await response.json();
                            this.showNotification('error', data.message || 'Không thể xóa mục kiểm tra', 'alert-triangle');
                        }
                    } catch (error) {
                        this.showNotification('error', 'Lỗi kết nối: ' + error.message, 'alert-triangle');
                    } finally {
                        this.deletingItem = false;
                        this.itemToDelete = null;
                    }
                },

          
            }
        }
    </script>
    @endraw
`
)