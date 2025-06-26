@import com.ship.management.entity.User
@import java.util.stream.Stream

@param User currentUser
!{var userId = currentUser.getId();}
!{var rootRole = currentUser.getRole().getRootRole().toString();}
!{var permissions = currentUser.getListAuthorities();}
@template.layout(
title = "Đánh giá tàu",
activePage = "reviews-ship",
currentUser = currentUser,
content = @`
    <script src="https://cdn.jsdelivr.net/npm/dayjs@1/dayjs.min.js"></script>

    <div x-data="reviewManager()" x-init="loadCompanies()" class="space-y-6">
        <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
            <div>
                <h1 class="text-2xl font-bold">Kiểm tra & Đánh giá tàu</h1>
                <p class="text-base-content/70">RIGHTSHIP INSPECTION & REVIEW</p>
            </div>
        </div>

        <div class="card bg-base-100 shadow-xl">
            <div class="card-body">
                <h3 class="font-semibold text-lg mb-4">Chọn công ty, tàu và mục kiểm tra</h3>
                <div class="grid grid-cols-1 lg:grid-cols-6 gap-4">
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

                    <div class="form-control">
                        <label class="label">
                            <span class="label-text">Mục kiểm tra</span>
                        </label>
                        <select
                                class="select select-bordered"
                                x-model="selectedTemplateId"
                                :disabled="!selectedShipId || loadingTemplates"
                        >
                            <option value="">Tất cả mục</option>
                            <template x-for="template in checklistTemplates" :key="template.id">
                                <option :value="template.id" x-text="template.section"></option>
                            </template>
                        </select>
                    </div>

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


                    @if(Stream.of("ROLE_ADMIN","REVIEW_MANAGEMENT").anyMatch(permissions::contains))
                        <button
                                class="btn btn-success"
                                @click="openAddTemplateModal()"
                                :disabled="!selectedShipId"
                        >
                            <i data-lucide="plus" class="w-4 h-4"></i>
                            Thêm mục kiểm tra
                        </button>
                        @template.import-btn()


                    @endif


                </div>

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

        <div x-show="showSearchBar" class="card bg-base-100 shadow-xl">
            <div class="card-body">
                <div class="flex items-center justify-between mb-4">
                    <h2 class="card-title">
                        <i data-lucide="clipboard-check" class="w-5 h-5"></i>
                        Bảng đánh giá tàu
                        <span x-show="selectedShipName" class="text-sm text-base-content/70"
                              x-text="'- ' + selectedShipName"></span>
                    </h2>
                    <div class="text-sm text-base-content/70">
                        <span x-text="displayedTemplates.length"></span> template,
                        <span x-text="getTotalItems()"></span> mục kiểm tra
                    </div>
                </div>

                <div x-show="loading" class="flex justify-center py-8">
                    <span class="loading loading-spinner loading-lg"></span>
                </div>

                <div x-show="!loading && displayedTemplates.length === 0" class="text-center py-8">
                    <i data-lucide="clipboard" class="w-16 h-16 mx-auto text-base-content/30 mb-4"></i>
                    <h3 class="text-lg font-medium mb-2">Chưa có mục kiểm tra nào</h3>

                </div>

                <div x-show="!loading && displayedTemplates.length > 0" class="overflow-x-auto">
                    <table class="table w-full ">
                        <thead>
                        <tr class="bg-base-100">
                            <th class="text-center w-16">STT</th>
                            <th class="min-w-48">Nội dung ra soát</th>
                            <th class="min-w-32">Hướng dẫn</th>
                            <th class="min-w-32">Tài liệu đính kèm</th>
                            <th class="min-w-32">Yêu cầu</th>

                            <th class="min-w-32">Người phụ trách</th>
                            <th class="text-center w-24">Đánh giá</th>
                            <th class="min-w-32">Người đánh giá tàu</th>
                            <th class="min-w-32">Người phụ trách từ Cty</th>
                            <th class="text-center w-24">Đánh giá từ Cty</th>
                            <th class="min-w-32">Note</th>
                            <th class="text-center w-20">Thao tác</th>
                        </tr>
                        </thead>
                        <template x-for="template in displayedTemplates" :key="template.id">
                            <tbody>
                            <tr class="bg-base-200 border-t-2 border-base-300 bg-base-400">
                                <%-- 13 --%>
                                <td colspan="5" class="p-4">
                                    <div class="flex items-center justify-start">
                                        <div class="flex items-center gap-4">
                                            <h3 class="text-lg font-bold" x-text="template.section"></h3>

                                            <span class="badge badge-info"
                                                  x-text="getItemCount(template) + ' mục'"></span>
                                        </div>

                                    </div>
                                </td>
                                <td>
                                    YES-NO-N/A
                                </td>
                                <td colspan="3">
                                </td>
                                <td>
                                    YES-NO-N/A
                                </td>

                                <td colspan="2">
                                    @if(Stream.of("ROLE_ADMIN","REVIEW_MANAGEMENT").anyMatch(permissions::contains))
                                        <div class="flex items-center gap-2 justify-end">

                                            <button @click="openCreateItemModal(template)"
                                                    class="btn btn-ghost btn-sm tooltip" data-tip="Thêm chi tiết">
                                                <i data-lucide="plus" class="w-4 h-4"></i>
                                            </button>
                                            <button @click="editTemplate(template)" class="btn btn-ghost btn-sm tooltip"
                                                    data-tip="Chỉnh sửa mục">
                                                <i data-lucide="edit" class="w-4 h-4"></i>
                                            </button>
                                            <button @click="deleteTemplate(template)"
                                                    class="btn btn-ghost btn-sm text-error tooltip" data-tip="Xóa mục">
                                                <i data-lucide="trash-2" class="w-4 h-4"></i>
                                            </button>
                                        </div>
                                    @endif
                                </td>
                            </tr>

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
                                        <div class="flex items-center gap-1"
                                             @click="openAttachmentModal(item)"
                                        >

                                            <i data-lucide="paperclip" class="w-3 h-3 text-gray-400"></i>
                                            <span class="text-xs" x-text="item.attachments.length + ' file'"></span>
                                        </div>
                                    </td>
                                    <td class="max-w-xs">
                                        <div class="text-xs" x-text="item.vesselRemark || '-'"></div>
                                    </td>
                                    <td>
                                        <div class="flex items-center gap-2">
                                            <div>
                                                <div class="text-xs font-bold" x-text="item.assignedToFullName"></div>
                                                <div class="text-xs text-gray-500"
                                                     x-text="item.assignedToRoleName"></div>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="text-center tooltip" :data-tip="formatDate(item.vesselReviewAt)">
                    <span class="badge"
                          :class="{
                              'badge-success': item.vesselResult === 'YES',
                              'badge-warning': item.vesselResult === 'NO',
                              'badge-neutral': !item.vesselResult || item.vesselResult === 'NA'
                          }"
                          x-text="item.vesselResult || 'N/A'">
                    </span>
                                    </td>

                                    <td>
                                        <div class="flex items-center gap-2">
                                            <div>
                                                <div class="text-xs font-medium"
                                                     x-text="item.vesselAssignedToFullName"></div>
                                                <div class="text-xs text-gray-500"
                                                     x-text="item.vesselAssignedToRoleName"></div>
                                            </div>
                                        </div>
                                    </td>

                                    <td>
                                        <div class="flex items-center gap-2">

                                            <div>
                                                <div class="text-xs font-medium"
                                                     x-text="item.comAssignedToFullName"></div>
                                                <div class="text-xs text-gray-500"
                                                     x-text="item.comAssignedToRoleName"></div>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="text-center tooltip" :data-tip="formatDate(item.comReviewAt)">
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
                                        <div class="text-xs" x-text="item.note || '-'"></div>
                                    </td>
                                    <td class="text-center">
                                        <div class="flex items-center gap-1">
                                            <div class="dropdown dropdown-left  dropdown-center">
                                                <div tabindex="0" role="button" class="btn m-1 btn-sm btn-ghost"><i
                                                            data-lucide="ellipsis-vertical"></i>️
                                                </div>
                                                <ul tabindex="0"
                                                    class="dropdown-content menu bg-base-100 rounded-box z-1 w-52 p-2 shadow-sm ">
                                                    <li><a @click="openAttachmentModal(item)">


                                                             file

                                                        </a></li>
                                                    @if(Stream.of("ROLE_COMPANY").anyMatch(permissions::contains))
                                                        <li><a @click="openReviewModal(item, 'SHIP')" class="text-warning" x-show="isAllowUserReview(item,'SHIP')">


                                                                Đánh giá tàu

                                                            </a></li>
                                                        <li><a @click="openReviewModal(item, 'COMPANY')" class="text-warning" x-show="isAllowUserReview(item,'COMPANY')">


                                                                Đánh giá từ Cty

                                                            </a></li>
                                                        <li><a @click="openRequireModal(item)" class="text-warning" x-show="isAllowUserReview(item,'REQUIRE')">


                                                                Yêu cầu

                                                            </a></li>
                                                        <li><a @click="openNoteModal(item)" class="text-warning" x-show="isAllowUserReview(item,'NOTE')">


                                                                Note

                                                            </a></li>
                                                    @endif
                                                    @if(Stream.of("ROLE_ADMIN","REVIEW_MANAGEMENT").anyMatch(permissions::contains))
                                                        <li><a @click="openReorderModal(item)" class="text-warning">


                                                                Sắp xếp

                                                            </a></li>
                                                        <li><a @click="editChecklistItem(item)" class="text-warning">


                                                                Chỉnh sửa

                                                            </a></li>
                                                        <li><a @click="deleteChecklistItem(item)" class="text-error">


                                                                Xóa

                                                            </a></li>
                                                    @endif
                                                </ul>
                                            </div>


                                        </div>
                                    </td>
                                </tr>
                            </template>
                            </tbody>
                        </template>
                        <tr>
                            <td colspan="13" class="h-20"></td>
                        </tr>


                    </table>
                </div>

                @if(Stream.of("ROLE_ADMIN","REVIEW_MANAGEMENT").anyMatch(permissions::contains))
                    <div x-show="!loading && displayedTemplates.length > 0"
                         class="mt-6 grid grid-cols-1 md:grid-cols-3 gap-4">
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
                @endif
            </div>
        </div>

        <div class="modal" :class="{ 'modal-open': showTemplateModal }">
            <div class="modal-box">
                <h3 class="font-bold text-lg mb-4">
                    <span x-show="!editingTemplate">Thêm Mục Mới</span>
                    <span x-show="editingTemplate">Chỉnh sửa Mục</span>
                </h3>

                <form @submit.prevent="saveTemplate()" class="space-y-4">
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
       
        <div class="modal" :class="{ 'modal-open': showReviewModal }">
            <div class="modal-box">
                <h3 class="font-bold text-lg mb-4">Đánh giá <span class="text-warning" x-text="type=='SHIP'?'tàu':'Công ty'"></span></h3>
                <p class="text-sm text-base-content/70 mb-4" x-show="reviewItem">
                    Mục: <span class="font-medium" x-text="reviewItem?.content"></span>
                </p>
                <form @submit.prevent="saveReview()" class="space-y-4">
                    <div class="form-control">
                        <label class="label">
                        <span class="label-text">Kết quả
                         <span class="text-error">*</span>
                        </span>
                        </label>
                        <select class="select select-bordered" required x-model="reviewForm.result">
                            <option value="">N/A</option>
                            <option value="YES">YES</option>
                            <option value="NO">NO</option>
                        </select>
                    </div>
                    <div class="modal-action">
                        <button type="button" class="btn btn-ghost" @click="closeReviewModal()">Hủy</button>
                        <button type="submit" class="btn btn-primary" :disabled="savingReview">
                            <span x-show="savingReview" class="loading loading-spinner loading-sm"></span>
                            <span x-show="!savingReview">Lưu</span>
                        </button>
                    </div>
                </form>
            </div>
            <div class="modal" :class="{ 'modal-open': showDeleteModal }">
                <div class="modal-box">
                    <h3 class="font-bold text-lg mb-4 text-error">Xác nhận xóa</h3>
                    <p class="mb-4">
                        Bạn có chắc chắn muốn xóa mục kiểm tra <strong x-text="templateToDelete?.section"></strong>?
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

            <div class="modal" :class="{ 'modal-open': showCreateItemModal }">
                <div class="modal-box max-w-2xl">
                    <h3 class="font-bold text-lg mb-4">Thêm mục kiểm tra mới</h3>
                    <p class="text-sm text-base-content/70 mb-4" x-show="selectedTemplate">
                        Template: <span class="font-medium" x-text="selectedTemplate?.section"></span>
                    </p>

                    <form @submit.prevent="saveChecklistItem()" class="space-y-4">
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
                                    <option :value="user.id"
                                            x-text="user.fullName + ' (' + user.roleName + ')'"></option>
                                </template>
                            </select>
                            <label class="label" x-show="itemErrors.assignedToId">
                                <span class="label-text-alt text-error" x-text="itemErrors.assignedToId"></span>
                            </label>
                        </div>

                        <div class="form-control">
                            <label class="label">
                                <span class="label-text">Người đánh giá tàu <span class="text-error">*</span></span>
                            </label>
                            <select
                                    class="select select-bordered"
                                    :class="{ 'select-error': itemErrors.vesselAssignedToId }"
                                    x-model="itemForm.vesselAssignedToId"
                                    required
                            >
                                <option value="">Chọn người đánh giá</option>
                                <template x-for="user in getCompanyUsers()" :key="user.id">
                                    <option :value="user.id"
                                            x-text="user.fullName + ' (' + user.roleName + ')'"></option>
                                </template>
                            </select>
                            <label class="label" x-show="itemErrors.vesselAssignedToId">
                                <span class="label-text-alt text-error" x-text="itemErrors.vesselAssignedToId"></span>
                            </label>
                        </div>

                        <div class="form-control">
                            <label class="label">
                                <span class="label-text">Người phụ trách (Công ty) <span
                                            class="text-error">*</span></span>
                            </label>
                            <select
                                    class="select select-bordered"
                                    :class="{ 'select-error': itemErrors.comAssignedToId }"
                                    x-model="itemForm.comAssignedToId"
                                    required
                            >
                                <option value="">Chọn người phụ trách</option>
                                <template x-for="user in getCompanyUsers()" :key="user.id">
                                    <option :value="user.id"
                                            x-text="user.fullName + ' (' + user.roleName + ')'"></option>
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

            <div class="modal" :class="{ 'modal-open': showEditItemModal }">
                <div class="modal-box max-w-2xl">
                    <h3 class="font-bold text-lg mb-4">Chỉnh sửa mục kiểm tra</h3>
                    <p class="text-sm text-base-content/70 mb-4" x-show="editingItem">
                        Mục: <span class="font-medium" x-text="editingItem?.content"></span>
                    </p>

                    <form @submit.prevent="saveEditChecklistItem()" class="space-y-4">
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

                        <div class="form-control">

                            <label class="label" x-show="editItemErrors.orderNo">
                                <span class="label-text-alt text-error" x-text="editItemErrors.orderNo"></span>
                            </label>
                        </div>

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
                                    <option :value="user.id"
                                            x-text="user.fullName + ' (' + user.roleName + ')'"></option>
                                </template>
                            </select>
                            <label class="label" x-show="editItemErrors.assignedToId">
                                <span class="label-text-alt text-error" x-text="editItemErrors.assignedToId"></span>
                            </label>
                        </div>

                        <div class="form-control">
                            <label class="label">
                                <span class="label-text">Người đánh giá tàu <span class="text-error">*</span></span>
                            </label>
                            <select
                                    class="select select-bordered"
                                    :class="{ 'select-error': editItemErrors.vesselAssignedToId }"
                                    x-model="editItemForm.vesselAssignedToId"
                                    required
                            >
                                <option value="">Chọn người đánh giá</option>
                                <template x-for="user in getCompanyUsers()" :key="user.id">
                                    <option :value="user.id"
                                            x-text="user.fullName + ' (' + user.roleName + ')'"></option>
                                </template>
                            </select>
                            <label class="label" x-show="editItemErrors.vesselAssignedToId">
                                <span class="label-text-alt text-error" x-text="editItemErrors.vesselAssignedToId"></span>
                            </label>
                        </div>

                        <div class="form-control">
                            <label class="label">
                                <span class="label-text">Người phụ trách (Công ty) <span
                                            class="text-error">*</span></span>
                            </label>
                            <select
                                    class="select select-bordered"
                                    :class="{ 'select-error': editItemErrors.comAssignedToId }"
                                    x-model="editItemForm.comAssignedToId"
                                    required
                            >
                                <option value="">Chọn người phụ trách</option>
                                <template x-for="user in getCompanyUsers()" :key="user.id">
                                    <option :value="user.id"
                                            x-text="user.fullName + ' (' + user.roleName + ')'"></option>
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

            <div class="modal" :class="{ 'modal-open': showAttachmentModal }">
                <div class="modal-box max-w-4xl">
                    <h3 class="font-bold text-lg mb-4">
                        <i data-lucide="paperclip" class="w-5 h-5 inline mr-2"></i>
                        Quản lý tài liệu đính kèm
                    </h3>
                    <p class="text-sm text-base-content/70 mb-4" x-show="selectedAttachmentItem">
                        Mục kiểm tra: <span class="font-medium" x-text="selectedAttachmentItem?.content"></span>
                    </p>

                    @if(rootRole == "SHIP")
                        <div
                                x-show="isAllowReview(selectedAttachmentItem)"
                                class="card bg-base-200 mb-6">
                            <div class="card-body p-4">
                                <h4 class="font-medium mb-3">Tải lên tài liệu mới</h4>

                                <div class="flex flex-col lg:flex-row gap-4 mb-4">
                                    <div class="flex-1">
                                        <input type="file"
                                               class="file-input file-input-bordered file-input-sm w-full"
                                               @change="handleSingleFileSelect"
                                        >
                                    </div>
                                    <button @click="uploadSingleFile()"
                                            :disabled="!selectedFile || uploadingSingle"
                                            class="btn btn-primary btn-sm">
                                        <span x-show="uploadingSingle"
                                              class="loading loading-spinner loading-sm"></span>
                                        <span x-show="!uploadingSingle">
                                    <i data-lucide="upload" class="w-4 h-4 mr-2"></i>
                                    Tải lên file
                                </span>
                                    </button>
                                </div>

                                <div class="divider text-xs">HOẶC</div>
                                <div class="flex flex-col lg:flex-row gap-4">
                                    <div class="flex-1">
                                        <input type="file"
                                               multiple
                                               class="file-input file-input-bordered file-input-sm w-full"
                                               @change="handleMultipleFilesSelect"
                                        >
                                    </div>
                                    <button @click="uploadMultipleFiles()"
                                            :disabled="!selectedFiles?.length || uploadingMultiple"
                                            class="btn btn-success btn-sm">
                                        <span x-show="uploadingMultiple"
                                              class="loading loading-spinner loading-sm"></span>
                                        <span x-show="!uploadingMultiple">
                                    <i data-lucide="upload" class="w-4 h-4 mr-2"></i>
                                    Tải lên nhiều file
                                </span>
                                    </button>
                                </div>
                            </div>
                        </div>
                    @endif

                    <div class="card bg-base-100">
                        <div class="card-body p-4">
                            <div class="flex items-center justify-between mb-4">
                                <h4 class="font-medium">Danh sách tài liệu</h4>
                                <button @click="loadAttachments()" class="btn btn-ghost btn-sm">
                                    <i data-lucide="refresh-cw" class="w-4 h-4"></i>
                                    Làm mới
                                </button>
                            </div>

                            <div x-show="loadingAttachments" class="flex justify-center py-8">
                                <span class="loading loading-spinner loading-lg"></span>
                            </div>

                            <div x-show="!loadingAttachments && attachments.length === 0" class="text-center py-8">
                                <i data-lucide="file-x" class="w-16 h-16 mx-auto text-base-content/30 mb-4"></i>
                                <h5 class="text-lg font-medium mb-2">Chưa có tài liệu nào</h5>
                                <p class="text-base-content/70">Tải lên tài liệu đầu tiên cho mục kiểm tra này</p>
                            </div>

                            <div x-show="!loadingAttachments && attachments.length > 0" class="overflow-x-auto">
                                <table class="table table-zebra w-full text-sm">
                                    <thead>
                                    <tr>
                                        <th class="w-16">#</th>
                                        <th>Tên file</th>
                                        <th>Người tải lên</th>
                                        <th>Ngày tải lên</th>
                                        <th class="w-32">Thao tác</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <template x-for="(attachment, index) in attachments" :key="attachment.id">
                                        <tr>
                                            <td class="text-center" x-text="index + 1"></td>
                                            <td>
                                                <div class="flex items-center gap-2 ">

                                                    <i data-lucide="file" class="w-4 h-4 text-blue-500"></i>
                                                    <span x-text="attachment.filename" class="font-medium"></span>
                                                </div>
                                            </td>
                                            <td>
                                                <div>
                                                    <div class="font-medium" x-text="attachment.uploadedByName"></div>
                                                    <div class="text-xs text-gray-500"
                                                         x-text="formatDate(attachment.uploadedAt)"></div>
                                                </div>
                                            </td>
                                            <td x-text="formatDate(attachment.uploadedAt)"></td>
                                            <td>
                                                <div class="flex items-center gap-1">
                                                    <button @click="downloadFile(attachment)"
                                                            class="btn btn-ghost btn-xs tooltip"
                                                            data-tip="Xem">
                                                        xem
                                                    </button>
                                                    @if(rootRole == "SHIP")
                                                        <button @click="deleteAttachment(attachment)"
                                                                class="btn btn-ghost btn-xs text-error tooltip"
                                                                data-tip="Xóa">
                                                            xóa
                                                        </button>
                                                    @endif
                                                </div>
                                            </td>
                                        </tr>
                                    </template>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                    <div class="modal-action">
                        <button type="button" class="btn btn-ghost" @click="closeAttachmentModal()">Đóng</button>
                    </div>
                </div>
                <div class="modal-backdrop" @click="closeAttachmentModal()"></div>
            </div>

            <div class="modal" :class="{ 'modal-open': showDeleteAttachmentModal }">
                <div class="modal-box">
                    <h3 class="font-bold text-lg mb-4 text-error">Xác nhận xóa tài liệu</h3>
                    <p class="mb-4">
                        Bạn có chắc chắn muốn xóa tài liệu này không?
                        <br><strong x-text="attachmentToDelete?.filename"></strong>
                        <br>Hành động này không thể hoàn tác.
                    </p>
                    <div class="modal-action">
                        <button class="btn btn-ghost" @click="showDeleteAttachmentModal = false">Hủy</button>
                        <button class="btn btn-error" @click="confirmDeleteAttachment()" :disabled="deletingAttachment">
                            <span x-show="deletingAttachment" class="loading loading-spinner loading-sm"></span>
                            <span x-show="!deletingAttachment">Xóa</span>
                        </button>
                    </div>
                </div>
                <div class="modal-backdrop" @click="showDeleteAttachmentModal = false"></div>
            </div>

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

         <div class="modal" :class="{ 'modal-open': showRequireModal }">
            <div class="modal-box">
                <h3 class="font-bold text-lg mb-4">Cập nhật yêu cầu</h3>
                <form @submit.prevent="saveRequire()" class="space-y-4">
                    <div class="form-control">
                        <label class="label">
                            <span class="label-text">Yêu cầu</span>
                        </label>
                        <textarea class="textarea textarea-bordered" x-model="requireForm.remark"></textarea>
                    </div>
                    <div class="modal-action">
                        <button type="button" class="btn btn-ghost" @click="closeRequireModal()">Hủy</button>
                        <button type="submit" class="btn btn-primary" :disabled="savingRequire">
                            <span x-show="savingRequire" class="loading loading-spinner loading-sm"></span>
                            <span x-show="!savingRequire">Lưu</span>
                        </button>
                    </div>
                </form>
            </div>
            <div class="modal-backdrop" @click="closeRequireModal()"></div>

        </div>
        <div class="modal" :class="{ 'modal-open': showNoteModal }">
            <div class="modal-box">
                <h3 class="font-bold text-lg mb-4">Cập nhật note</h3>
                <form @submit.prevent="saveNote()" class="space-y-4">
                    <div class="form-control">
                        <label class="label">
                            <span class="label-text">Note</span>
                        </label>
                        <textarea class="textarea textarea-bordered" x-model="noteForm.remark"></textarea>
                    </div>
                    <div class="modal-action">
                        <button type="button" class="btn btn-ghost" @click="closeNoteModal()">Hủy</button>
                        <button type="submit" class="btn btn-primary" :disabled="savingNote">
                            <span x-show="savingNote" class="loading loading-spinner loading-sm"></span>
                            <span x-show="!savingNote">Lưu</span>
                        </button>
                    </div>
                </form>
            </div>
            <div class="modal-backdrop" @click="closeNoteModal()"></div>
        </div>
        <div class="modal" :class="{ 'modal-open': showReorderModal }">
            <div class="modal-box">
                <h3 class="font-bold text-lg mb-4">Sắp xếp</h3>
                <form @submit.prevent="saveReorder()" class="space-y-4">
                    <div class="form-control">
                        <label class="label">
                            <span class="label-text">Thứ tự</span>
                        </label>
                        <input type="number" class="input input-bordered" x-model="reorderForm.orderNo" required>
                    </div>
                    <div class="modal-action">
                        <button type="button" class="btn btn-ghost" @click="closeReorderModal()">Hủy</button>
                        <button type="submit" class="btn btn-primary" :disabled="savingReorder">
                            <span x-show="savingReorder" class="loading loading-spinner loading-sm"></span>
                            <span x-show="!savingReorder">Lưu</span>
                        </button>
                    </div>
                </form>
            </div>
            <div class="modal-backdrop" @click="closeReorderModal()"></div>
        </div>
    </div>
        <script>
            var rootRole = '${rootRole}';
            var currentUserId = ${currentUser.getId()};
            window.currentUserId = currentUserId;
        </script>
        @raw
        <script src="/review.js"></script>
          
    @endraw
`
)