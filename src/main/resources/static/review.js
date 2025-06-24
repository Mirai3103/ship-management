function reviewManager() {
    return {
        showRequireModal: false,
        requireForm: {
            remark: ''
        },
        savingRequire: false,
        showNoteModal: false,
        noteForm: {
            remark: ''
        },
        savingNote: false,
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
        showReviewModal: false,
        reviewItem: null,
        savingReview: false,
        reviewForm: {
            result: '',
            remark: '',
            note: ''
        },
        


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
        type: 'NONE',
        editItemErrors: {},


        showAttachmentModal: false,
        showDeleteAttachmentModal: false,
        selectedAttachmentItem: null,
        attachments: [],
        attachmentToDelete: null,
        loadingAttachments: false,
        selectedFile: null,
        selectedFiles: null,
        uploadingSingle: false,
        uploadingMultiple: false,
        deletingAttachment: false,
        showReorderModal: false,
        reorderForm: {
            templateId: '',
            checklistId: '',
            orderNo: 0
        },
        reorderErrors: {},
        savingReorder: false,

        async loadCompanies() {
            try {
                const response = await fetch('/api/companies?page=0&size=1000&strict=true');
                if (response.ok) {
                    const data = await response.json();
                    this.companies = data.content || [];
                }
            } catch (error) {
                console.error('Failed to load companies:', error);
                this.showNotification('error', 'Không thể tải danh sách công ty', 'alert-triangle');
            }
        },
        openReviewModal(item, type) {
            this.reviewItem = item;
            this.type = type;

            this.reviewForm = {
                result: '',
                remark: '',
                note: '',
            };
            this.showReviewModal = true;
        },
        closeReviewModal() {
            this.showReviewModal = false;
            this.reviewItem = null;
            this.reviewForm = {
                result: '',
                remark: '',
                note: ''
            };
        },
        openRequireModal(item) {
            this.reviewItem = item;
            this.showRequireModal = true;
        },
        closeRequireModal() {
            this.showRequireModal = false;
        },
        openNoteModal(item) {
            this.reviewItem = item;
            this.showNoteModal = true;
        },
        closeNoteModal() {
            this.showNoteModal = false;
        },
        async saveRequire() {
                // same api with review but type is REQUIRE
                this.savingRequire = true;
                const payload = {
                    id: this.reviewItem.id,
                    remark: this.requireForm.remark,
                    reviewType: 'REQUIRE'
                };
                const response = await fetch(`/api/checklist-items/${this.reviewItem.id}/review`, {
                    method: 'PATCH',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify(payload)
                });
                const data = await response.json();
                if (response.ok) {
                    this.closeRequireModal();
                    this.showNotification('success', 'Đã lưu yêu cầu thành công', 'check-circle');
                    await this.refreshTable();
                } else {
                    this.showNotification('error', data.message || 'Không thể lưu yêu cầu', 'alert-triangle');
                }
                this.savingRequire = false;
        },
      async  saveNote() {
            // same api with review but type is NOTE
            this.savingNote = true;
            const payload = {
                id: this.reviewItem.id,
                note: this.noteForm.remark,
                reviewType: 'NOTE'
            };
            const response = await fetch(`/api/checklist-items/${this.reviewItem.id}/review`, {
                method: 'PATCH',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(payload)
            });
            const data = await response.json();
            if (response.ok) {
                this.closeNoteModal();
                this.showNotification('success', 'Đã lưu note thành công', 'check-circle');
                await this.refreshTable();
            } else {
                this.showNotification('error', data.message || 'Không thể lưu note', 'alert-triangle');
            }
            this.savingNote = false;
            this.savingNote = false;
        },

        async saveReview() {
            console.log(this.reviewItem);
            if (!this.reviewForm.result ) {
                this.showNotification('warning', 'Vui lòng điền đầy đủ thông tin đánh giá', 'alert-triangle');
                return;
            }

            this.savingReview = true;

            try {
                const reviewData = {
                    id: this.reviewItem.id,
                    result: this.reviewForm.result,
                    remark: this.reviewForm.remark,
                    note: this.reviewForm.note || '',
                    reviewType: this.type
                };

                const response = await fetch(`/api/checklist-items/${this.reviewItem.id}/review`, {
                    method: 'PATCH',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify(reviewData)
                });

                const data = await response.json();

                if (response.ok) {
                    this.closeReviewModal();
                    this.showNotification('success', 'Đã lưu đánh giá thành công', 'check-circle');


                    this.updateItemInTemplates(data);
                    await this.refreshTable()

                } else {
                    this.showNotification('error', data.message || 'Không thể lưu đánh giá', 'alert-triangle');
                }
            } catch (error) {
                console.error('Failed to save review:', error);
                this.showNotification('error', 'Lỗi kết nối: ' + error.message, 'alert-triangle');
            } finally {
                this.savingReview = false;
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
                const response = await fetch(`/api/ships/company/${this.selectedCompanyId}?page=0&size=1000&strict=true`);
                if (response.ok) {
                    const data = await response.json();

                    this.ships = data || [];
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


            const selectedShip = this.ships.find(ship => ship.id == this.selectedShipId);
            this.selectedShipName = selectedShip ? selectedShip.name : '';

            try {
                const response = await fetch(`/api/checklist-templates/ship/${this.selectedShipId}/ordered`);
                if (response.ok) {
                    this.checklistTemplates = await response.json();
                    this.usersOfShip = await fetch(`/api/ships/${this.selectedShipId}/users`).then(res => res.json());
                    this.sortChecklistTemplatesEachItem();
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
        async sortChecklistTemplatesEachItem() {
            this.checklistTemplates.forEach(template => {
                template.checklistItems.sort((a, b) => a.orderNo - b.orderNo);
            });
        },
        async loadReviews() {
            if (!this.selectedCompanyId || !this.selectedShipId) {
                console.log('Missing company or ship ID');
                return;
            }

            this.loading = true;
            console.log('Loading reviews for ship:', this.selectedShipId, 'Available templates:', this.checklistTemplates.length);

            try {

                if (this.selectedTemplateId) {
                    this.displayedTemplates = this.checklistTemplates.filter(
                        template => template.id == this.selectedTemplateId
                    );
                } else {
                    this.displayedTemplates = [...this.checklistTemplates];
                }

                console.log('Displayed templates:', this.displayedTemplates.length);


                this.showSearchBar = true;

                if (this.displayedTemplates.length === 0) {
                    this.showNotification('info', 'Chưa có mục kiểm tra nào cho tàu này. Hãy thêm mục kiểm tra mới!', 'info');
                } else {
                    this.showNotification('success', `Đã tải ${this.displayedTemplates.length} mục kiểm tra thành công`, 'check-circle');
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


        openAddTemplateModal() {
            this.editingTemplate = null;
            this.templateForm = {section: '', orderNo: 0};
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
            this.templateForm = {section: '', orderNo: 0};
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
                    await this.refreshTable();

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
        async refreshTable() {
            await this.loadChecklistTemplates();
            setTimeout(() => {
                this.loadReviews();
            }, 500);
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
                    await this.refreshTable();
                    this.showNotification('success', `Đã xóa mục kiểm tra "${this.templateToDelete.section}" thành công`, 'check-circle');
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
        isAllowReview(item) {
            // if (rootRole === 'SHIP') {
            //     return item.vesselReviewAt == null;
            // } else if (rootRole === 'COMPANY') {
            //     return item.comReviewAt == null;
            // }
            return true;
        },
        isAllowUserReview(item) {
            var currentUserId = window.currentUserId;
            if (item.comAssignedToId == currentUserId) {
                return true;
            }
            return false;
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

            return {yes, no, na};
        },

        showNotification(type, message, icon) {
            const ranFrom1To1000 = Math.floor(Math.random() * 1000) + 1;
            const notification = {
                id: Date.now().toString() + ranFrom1To1000,
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

        updateItemInTemplates(updatedItem) {

            this.displayedTemplates.forEach(template => {
                if (template.checklistItems) {
                    const itemIndex = template.checklistItems.findIndex(item => item.id === updatedItem.id);
                    if (itemIndex !== -1) {

                        template.checklistItems[itemIndex] = {
                            ...template.checklistItems[itemIndex],
                            ...updatedItem
                        };
                    }
                }
            });


            this.checklistTemplates.forEach(template => {
                if (template.checklistItems) {
                    const itemIndex = template.checklistItems.findIndex(item => item.id === updatedItem.id);
                    if (itemIndex !== -1) {
                        template.checklistItems[itemIndex] = {
                            ...template.checklistItems[itemIndex],
                            ...updatedItem
                        };
                    }
                }
            });
        },


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

                    await this.refreshTable();
                } else {

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

                    await this.refreshTable();
                } else {

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

                    await this.refreshTable();
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


        handleSingleFileSelect(event) {
            const file = event.target.files[0];
            this.selectedFile = file;
        },

        openAttachmentModal(item) {
            this.selectedAttachmentItem = item;
            this.showAttachmentModal = true;
            this.loadAttachments();
        },

        closeAttachmentModal() {
            this.showAttachmentModal = false;
            this.selectedAttachmentItem = null;
            this.attachments = [];
            this.selectedFile = null;
            this.selectedFiles = null;

            const fileInputs = document.querySelectorAll('input[type="file"]');
            fileInputs.forEach(input => input.value = '');
        },

        getAttachmentCount(item) {

            if (this.selectedAttachmentItem && this.selectedAttachmentItem.id === item.id) {
                return this.attachments.length;
            }

            return item.attachmentCount || 0;
        },

        formatDate(dateString) {

            if (!dateString) return '-';
            try {
                return new Date(dateString).toLocaleDateString('vi-VN', {
                    day: '2-digit',
                    month: '2-digit',
                    year: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit'
                });
            } catch (error) {
                return dateString;
            }
        },

        handleMultipleFilesSelect(event) {
            const files = event.target.files;
            this.selectedFiles = Array.from(files);
        },
        async uploadSingleFile() {
            if (!this.selectedFile) {
                this.showNotification('warning', 'Vui lòng chọn tài liệu để tải lên', 'alert-triangle');
                return;
            }

            this.uploadingSingle = true;

            try {
                const formData = new FormData();
                formData.append('file', this.selectedFile);
                formData.append('checklistItemId', this.selectedAttachmentItem.id);
                formData.append('uploadedById', currentUserId); // Use current user ID

                const response = await fetch('/api/attachments/upload/single', {
                    method: 'POST',
                    body: formData
                });

                const data = await response.json();

                if (response.ok && data.success) {
                    this.showNotification('success', data.message || 'Tài liệu đã được tải lên thành công', 'check-circle');
                    await this.loadAttachments(); // Reload attachments list

                    this.selectedFile = null;
                    const fileInput = document.querySelector('input[type="file"]:not([multiple])');
                    if (fileInput) fileInput.value = '';
                } else {
                    this.showNotification('error', data.message || 'Không thể tải lên tài liệu', 'alert-triangle');
                }
            } catch (error) {
                this.showNotification('error', 'Lỗi kết nối: ' + error.message, 'alert-triangle');
            } finally {
                this.uploadingSingle = false;
            }
        },
        getFinalResult(template, field) {
        },
        async uploadMultipleFiles() {
            if (!this.selectedFiles || this.selectedFiles.length === 0) {
                this.showNotification('warning', 'Vui lòng chọn tài liệu để tải lên', 'alert-triangle');
                return;
            }

            this.uploadingMultiple = true;

            try {
                const formData = new FormData();
                this.selectedFiles.forEach((file) => {
                    formData.append('files', file);
                });
                formData.append('checklistItemId', this.selectedAttachmentItem.id);
                formData.append('uploadedById', currentUserId); // Use current user ID

                const response = await fetch('/api/attachments/upload/multiple', {
                    method: 'POST',
                    body: formData
                });

                const data = await response.json();

                if (response.ok && data.success) {
                    this.showNotification('success', data.message || 'Tài liệu đã được tải lên thành công', 'check-circle');
                    await this.loadAttachments(); // Reload attachments list

                    this.selectedFiles = null;
                    const fileInput = document.querySelector('input[type="file"][multiple]');
                    if (fileInput) fileInput.value = '';
                } else {
                    this.showNotification('error', data.message || 'Không thể tải lên tài liệu', 'alert-triangle');
                }
            } catch (error) {
                this.showNotification('error', 'Lỗi kết nối: ' + error.message, 'alert-triangle');
            } finally {
                this.uploadingMultiple = false;
            }
        },
        async loadAttachments() {
            if (!this.selectedAttachmentItem) return;

            this.loadingAttachments = true;

            try {
                const response = await fetch(`/api/attachments/checklist-item/${this.selectedAttachmentItem.id}`);
                if (response.ok) {
                    this.attachments = await response.json();
                } else {
                    this.attachments = [];
                }
            } catch (error) {
                console.error('Failed to load attachments:', error);
                this.attachments = [];
                this.showNotification('error', 'Không thể tải danh sách tài liệu', 'alert-triangle');
            } finally {
                this.loadingAttachments = false;
            }
        },
        downloadFile(attachment) {

            const filename = attachment.fileUrl ? attachment.fileUrl.split('/').pop() : attachment.filename;
            const downloadUrl = `/api/attachments/download/${filename}`;


            const link = document.createElement('a');
            link.href = downloadUrl;
            link.target = '_blank';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        },
        deleteAttachment(attachment) {
            this.attachmentToDelete = attachment;
            this.showDeleteAttachmentModal = true;
        },
        async confirmDeleteAttachment() {
            this.deletingAttachment = true;
            try {
                const response = await fetch(`/api/attachments/${this.attachmentToDelete.id}`, {
                    method: 'DELETE'
                });

                if (response.ok) {
                    this.showDeleteAttachmentModal = false;
                    this.showNotification('success', 'Đã xóa tài liệu thành công', 'check-circle');
                    await this.loadAttachments(); // Reload attachments list only
                } else {
                    const data = await response.json();
                    this.showNotification('error', data.message || 'Không thể xóa tài liệu', 'alert-triangle');
                }
            } catch (error) {
                this.showNotification('error', 'Lỗi kết nối: ' + error.message, 'alert-triangle');
            } finally {
                this.deletingAttachment = false;
                this.attachmentToDelete = null;
            }
        },
        openReorderModal(item) {
            this.reorderForm = {
                templateId: item.checklistTemplateId,
                checklistId: item.id,
                orderNo: item.orderNo
            };
            this.showReorderModal = true;
        },
        closeReorderModal() {
            this.showReorderModal = false;
            this.reorderForm = {
                templateId: '',
                checklistId: '',
                orderNo: 0
            };
        },
        async saveReorder() {
            this.savingReorder = true;
            try {
                const response = await fetch('/api/checklist-items/update-order', {
                    method: 'PATCH',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify(this.reorderForm)
                });
                const data = await response.json();
                if (response.ok) {
                    this.closeReorderModal();
                    this.showNotification('success', 'Đã cập nhật thứ tự thành công', 'check-circle');
                    await this.refreshTable();
                } else {
                    this.showNotification('error', data.message || 'Không thể cập nhật thứ tự', 'alert-triangle');
                }
            } catch (error) {
                this.showNotification('error', 'Lỗi kết nối: ' + error.message, 'alert-triangle');
            } finally {
                this.savingReorder = false;
            }
        }
    }
}