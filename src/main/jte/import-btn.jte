<div x-data="importManager()" class="inline-block">
        <button
        class="btn btn-info"
        @click="openImportModal()"
        :disabled="!canImport || !selectedShipId"
    >
        <i data-lucide="download" class="w-4 h-4"></i>
        Nhập từ tàu khác
    </button>

        <div class="modal" :class="{ 'modal-open': showImportModal }">
        <div class="modal-box max-w-full" style="width: 700px;">
            <h3 class="font-bold text-lg mb-4">
                <i data-lucide="download" class="w-5 h-5 inline mr-2"></i>
                Nhập mục kiểm tra từ tàu khác
            </h3>

                        <div x-show="currentStep === 1" class="space-y-4">
                <div class="alert alert-info">
                    <i data-lucide="info" class="w-4 h-4"></i>
                    <span>Bước 1: Chọn công ty và tàu nguồn để nhập mục kiểm tra</span>
                </div>

                <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
                                        <div class="form-control">
                        <label class="label">
                            <span class="label-text">Công ty nguồn <span class="text-error">*</span></span>
                        </label>
                        <select
                            class="select select-bordered"
                            x-model="importForm.sourceCompanyId"
                            @change="loadSourceShips()"
                            required
                        >
                            <option value="">Chọn công ty nguồn</option>
                            <template x-for="company in importCompanies" :key="company.id">
                                <option :value="company.id" x-text="company.name"></option>
                            </template>
                        </select>
                    </div>

                                        <div class="form-control">
                        <label class="label">
                            <span class="label-text">Tàu nguồn <span class="text-error">*</span></span>
                        </label>
                        <select
                            class="select select-bordered"
                            x-model="importForm.sourceShipId"
                            :disabled="!importForm.sourceCompanyId || loadingImportShips"
                            required
                        >
                            <option value="">Chọn tàu nguồn</option>
                            <template x-for="ship in importShips" :key="ship.id">
                                <option :value="ship.id" x-text="ship.name"></option>
                            </template>
                        </select>
                    </div>
                </div>

                <div class="flex justify-end gap-2 mt-6">
                    <button class="btn btn-ghost" @click="closeImportModal()">Hủy</button>
                    <button 
                        class="btn btn-primary" 
                        @click="loadSourceChecklists()"
                        :disabled="!importForm.sourceCompanyId || !importForm.sourceShipId || loadingImportTemplates"
                    >
                        <span x-show="loadingImportTemplates" class="loading loading-spinner loading-sm"></span>
                        <span x-show="!loadingImportTemplates">Tiếp theo</span>
                    </button>
                </div>
            </div>

                        <div x-show="currentStep === 2" class="space-y-4">
                <div class="alert alert-success">
                    <i data-lucide="check-circle" class="w-4 h-4"></i>
                    <span>Bước 2: Chọn mục kiểm tra muốn nhập</span>
                    <div class="text-sm text-base-content/70">
                        Tàu nguồn: <span class="font-medium" x-text="getSelectedShipName()"></span>
                    </div>
                </div>

                                <div class="flex items-center justify-between bg-base-200 p-4 rounded-lg">
                    <div class="flex items-center gap-4">
                        <label class="label cursor-pointer">
                            <input type="checkbox" 
                                   class="checkbox checkbox-primary" 
                                   :checked="isAllSelected()"
                                   @change="toggleSelectAll()"
                            />
                            <span class="label-text ml-2">Chọn tất cả</span>
                        </label>
                        <div class="text-sm text-base-content/70">
                            Đã chọn: <span class="font-medium" x-text="getSelectedCount()"></span> mục
                        </div>
                    </div>
                    <button class="btn btn-ghost btn-sm" @click="clearAllSelections()">
                        <i data-lucide="x" class="w-4 h-4"></i>
                        Bỏ chọn tất cả
                    </button>
                </div>

                                <div x-show="loadingImportTemplates" class="flex justify-center py-8">
                    <span class="loading loading-spinner loading-lg"></span>
                </div>

                                <div x-show="!loadingImportTemplates && importTemplates.length === 0" class="text-center py-8">
                    <i data-lucide="clipboard" class="w-16 h-16 mx-auto text-base-content/30 mb-4"></i>
                    <h4 class="text-lg font-medium mb-2">Không có mục kiểm tra nào</h4>
                    <p class="text-base-content/70">Tàu này chưa có mục kiểm tra để nhập</p>
                </div>

                                <div x-show="!loadingImportTemplates && importTemplates.length > 0" class="overflow-x-auto max-h-96">
                    <table class="table table-zebra w-full">
                        <thead class="sticky top-0 bg-base-100 z-10">
                            <tr>
                                <th class="w-12">
                                    <input type="checkbox" 
                                           class="checkbox checkbox-primary" 
                                           :checked="isAllSelected()"
                                           @change="toggleSelectAll()"
                                    />
                                </th>
                                <th class="w-16">STT</th>
                                <th class="min-w-48">Nội dung ra soát</th>
                                <th class="min-w-32">Hướng dẫn</th>
                            </tr>
                        </thead>
                        <template x-for="template in importTemplates" :key="template.id">
                            <tbody>
                                                                <tr class="bg-base-200 border-t-2 border-base-300">
                                    <td>
                                        <input type="checkbox" 
                                               class="checkbox checkbox-secondary" 
                                               :checked="isTemplateSelected(template)"
                                               @change="toggleTemplateSelection(template)"
                                        />
                                    </td>
                                    <td colspan="3" class="font-bold">
                                        <div class="flex items-center gap-2">
                                            <span x-text="template.section"></span>
                                            <span class="badge badge-info badge-sm" 
                                                  x-text="getTemplateItemCount(template) + ' mục'"></span>
                                        </div>
                                    </td>
                                </tr>

                                                                <template x-for="(item, index) in getTemplateItems(template)" :key="template.id + '_' + item.id">
                                    <tr>
                                        <td>
                                            <input type="checkbox" 
                                                   class="checkbox checkbox-primary checkbox-sm" 
                                                   :checked="isItemSelected(template.id, item.id)"
                                                   @change="toggleItemSelection(template.id, item.id)"
                                            />
                                        </td>
                                        <td class="text-center font-mono text-sm" 
                                            x-text="String(index + 1).padStart(2, '0')"></td>
                                        <td class="max-w-xs">
                                            <div class="font-medium text-sm" x-text="item.content"></div>
                                        </td>
                                        <td class="max-w-xs">
                                            <div class="text-xs text-base-content/70" x-text="item.guide || '-'"></div>
                                        </td>
                                    </tr>
                                </template>
                            </tbody>
                        </template>
                    </table>
                </div>

                <div class="flex justify-between gap-2 mt-6">
                    <button class="btn btn-ghost" @click="backToStep1()">
                        <i data-lucide="arrow-left" class="w-4 h-4"></i>
                        Quay lại
                    </button>
                    <div class="flex gap-2">
                        <button class="btn btn-ghost" @click="closeImportModal()">Hủy</button>
                        <button 
                            class="btn btn-success" 
                            @click="submitImport()"
                            :disabled="getSelectedCount() === 0 || submittingImport"
                        >
                            <span x-show="submittingImport" class="loading loading-spinner loading-sm"></span>
                            <span x-show="!submittingImport">
                                <i data-lucide="download" class="w-4 h-4"></i>
                                Nhập <span x-text="'(' + getSelectedCount() + ' mục)'"></span>
                            </span>
                        </button>
                    </div>
                </div>
            </div>
        </div>
        <div class="modal-backdrop" @click="closeImportModal()"></div>
    </div>

        <div class="toast toast-top toast-end">
        <template x-for="notification in importNotifications" :key="notification.id">
            <div class="alert" :class="'alert-' + notification.type">
                <i :data-lucide="notification.icon" class="w-4 h-4"></i>
                <span x-text="notification.message"></span>
                <button @click="removeImportNotification(notification.id)" class="btn btn-ghost btn-xs">
                    <i data-lucide="x" class="w-3 h-3"></i>
                </button>
            </div>
        </template>
    </div>
</div>
@raw
<script>
function importManager() {
    return {

        showImportModal: false,
        currentStep: 1,
        canImport: true,


        importCompanies: [],
        importShips: [],
        importTemplates: [],
        

        loadingImportShips: false,
        loadingImportTemplates: false,
        submittingImport: false,


        importForm: {
            sourceCompanyId: '',
            sourceShipId: ''
        },


        selectedItems: {}, // {templateId: [itemId1, itemId2, ...]}


        importNotifications: [],


        async openImportModal() {
            this.showImportModal = true;
            this.currentStep = 1;
            this.resetImportForm();
            await this.loadImportCompanies();
        },

        closeImportModal() {
            this.showImportModal = false;
            this.currentStep = 1;
            this.resetImportForm();
        },

        resetImportForm() {
            this.importForm = {
                sourceCompanyId: '',
                sourceShipId: ''
            };
            this.importShips = [];
            this.importTemplates = [];
            this.selectedItems = {};
        },

        backToStep1() {
            this.currentStep = 1;
            this.importTemplates = [];
            this.selectedItems = {};
        },


        async loadImportCompanies() {
            try {
                const response = await fetch('/api/companies?page=0&size=1000&strict=true');
                if (response.ok) {
                    const data = await response.json();
                    this.importCompanies = data.content || [];
                }
            } catch (error) {
                console.error('Failed to load companies:', error);
                this.showImportNotification('error', 'Không thể tải danh sách công ty', 'alert-triangle');
            }
        },

        async loadSourceShips() {
            if (!this.importForm.sourceCompanyId) {
                this.importShips = [];
                this.importForm.sourceShipId = '';
                return;
            }

            this.loadingImportShips = true;
            this.importForm.sourceShipId = '';

            try {
                const response = await fetch(`/api/ships?page=0&size=1000&strict=true`);
                if (response.ok) {
                    const data = await response.json();
                    this.importShips = data.content || [];
                }
            } catch (error) {
                console.error('Failed to load ships:', error);
                this.importShips = [];
                this.showImportNotification('error', 'Không thể tải danh sách tàu', 'alert-triangle');
            } finally {
                this.loadingImportShips = false;
            }
        },

        async loadSourceChecklists() {
            if (!this.importForm.sourceShipId) return;

            this.loadingImportTemplates = true;

            try {
                const response = await fetch(`/api/checklist-templates/ship/${this.importForm.sourceShipId}/ordered`);
                if (response.ok) {
                    this.importTemplates = await response.json();
                    this.currentStep = 2;
                    
                    if (this.importTemplates.length === 0) {
                        this.showImportNotification('info', 'Tàu này chưa có mục kiểm tra nào', 'info');
                    } else {
                        this.showImportNotification('success', `Đã tải ${this.importTemplates.length} mục kiểm tra`, 'check-circle');
                    }
                } else {
                    this.showImportNotification('error', 'Không thể tải danh sách mục kiểm tra', 'alert-triangle');
                }
            } catch (error) {
                console.error('Failed to load checklist templates:', error);
                this.showImportNotification('error', 'Lỗi kết nối: ' + error.message, 'alert-triangle');
            } finally {
                this.loadingImportTemplates = false;
            }
        },


        getSelectedShipName() {
            const ship = this.importShips.find(s => s.id == this.importForm.sourceShipId);
            return ship ? ship.name : '';
        },

        getTemplateItems(template) {
            return template.checklistItems || [];
        },

        getTemplateItemCount(template) {
            return template.checklistItems ? template.checklistItems.length : 0;
        },


        isTemplateSelected(template) {
            const items = this.getTemplateItems(template);
            if (items.length === 0) return false;
            
            const templateSelections = this.selectedItems[template.id] || [];
            return items.every(item => templateSelections.includes(item.id));
        },

        isItemSelected(templateId, itemId) {
            const templateSelections = this.selectedItems[templateId] || [];
            return templateSelections.includes(itemId);
        },

        toggleTemplateSelection(template) {
            const items = this.getTemplateItems(template);
            if (items.length === 0) return;

            if (!this.selectedItems[template.id]) {
                this.selectedItems[template.id] = [];
            }

            const isCurrentlySelected = this.isTemplateSelected(template);
            
            if (isCurrentlySelected) {

                this.selectedItems[template.id] = [];
            } else {

                this.selectedItems[template.id] = items.map(item => item.id);
            }
        },

        toggleItemSelection(templateId, itemId) {
            if (!this.selectedItems[templateId]) {
                this.selectedItems[templateId] = [];
            }

            const index = this.selectedItems[templateId].indexOf(itemId);
            if (index > -1) {
                this.selectedItems[templateId].splice(index, 1);
            } else {
                this.selectedItems[templateId].push(itemId);
            }


            if (this.selectedItems[templateId].length === 0) {
                delete this.selectedItems[templateId];
            }
        },

        isAllSelected() {
            if (this.importTemplates.length === 0) return false;
            
            return this.importTemplates.every(template => {
                const items = this.getTemplateItems(template);
                if (items.length === 0) return true;
                return this.isTemplateSelected(template);
            });
        },

        toggleSelectAll() {
            const shouldSelectAll = !this.isAllSelected();
            
            if (shouldSelectAll) {

                this.importTemplates.forEach(template => {
                    const items = this.getTemplateItems(template);
                    if (items.length > 0) {
                        this.selectedItems[template.id] = items.map(item => item.id);
                    }
                });
            } else {

                this.selectedItems = {};
            }
        },

        clearAllSelections() {
            this.selectedItems = {};
        },

        getSelectedCount() {
            let count = 0;
            Object.values(this.selectedItems).forEach(items => {
                count += items.length;
            });
            return count;
        },


        async submitImport() {
            if (this.getSelectedCount() === 0) {
                this.showImportNotification('warning', 'Vui lòng chọn ít nhất một mục để nhập', 'alert-triangle');
                return;
            }

            this.submittingImport = true;

            try {

                const checklists = [];
                Object.entries(this.selectedItems).forEach(([templateId, itemIds]) => {
                    itemIds.forEach(itemId => {
                        checklists.push({
                            templateId: parseInt(templateId),
                            checklistId: itemId
                        });
                    });
                });

                const importData = {
                    shipId: this.selectedShipId,
                    checklists: checklists,
                    items: checklists.map(item => ({
                        templateId: item.templateId,
                        checklistId: item.checklistId
                    }))
                };

                console.log('Import data to be submitted:', importData);
                const response = await fetch('/api/checklist-items/copy', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify(importData)
                })
                if(response.ok){
                    this.showImportNotification('success', `Đã nhập thành công ${this.getSelectedCount()} mục kiểm tra`, 'check-circle');
                    this.closeImportModal();
                }else{
                    this.showImportNotification('error', 'Lỗi khi nhập: ' + response.statusText, 'alert-triangle');
                }


            } catch (error) {
                console.error('Failed to import checklists:', error);
                this.showImportNotification('error', 'Lỗi khi nhập: ' + error.message, 'alert-triangle');
            } finally {
             this.refreshTable()

                this.submittingImport = false;
            }
        },


        showImportNotification(type, message, icon) {
            const id = Date.now().toString() + Math.floor(Math.random() * 1000);
            const notification = {
                id: id,
                type: type,
                message: message,
                icon: icon
            };

            this.importNotifications.push(notification);

            setTimeout(() => {
                this.removeImportNotification(id);
            }, 5000);
        },

        removeImportNotification(id) {
            this.importNotifications = this.importNotifications.filter(n => n.id !== id);
        }
    }
}
</script>
    @endraw
