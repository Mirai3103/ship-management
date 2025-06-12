@template.layout(
title = "Đánh giá tàu",
activePage = "reviews-ship",
content = @`
    <div x-data="reviewManager()" x-init="loadCompanies()" class="space-y-6">
        <!-- Header Section -->
        <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
            <div>
                <h1 class="text-2xl font-bold">Kiểm tra & Đánh giá tàu</h1>
                <p class="text-base-content/70"> RIGHTSHIP INSPECTION & REVIEW </p>
            </div>
        </div>
        
        <!-- Company and Ship Selection -->
        <div class="card bg-base-100 shadow-xl">
            <div class="card-body">
                <h3 class="font-semibold text-lg mb-4">Chọn công ty và tàu</h3>
                <div class="grid grid-cols-1 lg:grid-cols-3 gap-1">
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
                            required
                        >
                            <option value="">
                                <span>Chọn tàu</span>
                            </option>
                            <template x-for="ship in ships" :key="ship.id">
                                <option :value="ship.id" x-text="ship.name"></option>
                            </template>
                        </select>
                    </div>

                    <!-- Load Button -->
                    <div class="form-control">
                        <label class="label">
                            <span class="label-text">&nbsp;</span>
                        </label>
                        <button 
                            class="btn btn-primary w-40"
                            @click="loadReviews()"
                            :disabled="!selectedCompanyId || !selectedShipId || loading"
                        >
                            <span x-show="loading" class="loading loading-spinner loading-sm "></span>
                            <span x-show="!loading" class="flex items-center gap-2">
                                <i data-lucide="download" class="w-4 h-4"></i>
                                Tải bảng
                            </span>
                        </button>
                    </div>
                </div>
                  <div class="flex flex-col lg:flex-row gap-4 mt-4 ml-4"  x-show="showSearchBar">
                    <div class="flex-1">
                        <div class="form-control">
                            <div class="input-group">
                                <input
                                    type="text"
                                    placeholder="Tìm kiếm trong kết quả..."
                                    class="input input-bordered flex-1"
                                    x-model="searchQuery"
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
                    </h2>
                    <div class="text-sm text-base-content/70">
                        Tổng số: <span class="font-semibold">5</span> mục kiểm tra
                    </div>
                </div>

                <div class="overflow-x-auto">
                    <table class="table table-zebra w-full text-sm">
                        <thead>
                            <tr class="bg-base-200">
                                <th class="text-center">STT</th>
                                <th>Nội dung ra soát</th>
                                <th>Hướng dẫn</th>
                                <th>Tài liệu đính kèm</th>
                                <th>Người phụ trách</th>
                                <th class="text-center">Đánh giá</th>
                                <th>Remark</th>
                                <th>Người phụ trách từ Cty</th>
                                <th class="text-center">Đánh giá từ Cty</th>
                                <th>Remark từ Cty</th>
                                <th>Note</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td class="text-center font-mono">01</td>
                                <td class="max-w-xs">
                                    <div class="font-medium">Kiểm tra giấy tờ tàu</div>
                                    <div class="text-xs text-gray-500">Xác minh tính hợp lệ của các giấy tờ</div>
                                </td>
                                <td class="max-w-xs">
                                    <div class="text-xs">Kiểm tra đăng ký tàu, giấy phép hoạt động, bảo hiểm</div>
                                </td>
                                <td>
                                    <div class="flex flex-col gap-1">
                                        <span class="badge badge-outline badge-xs">File_001.pdf</span>
                                        <span class="badge badge-outline badge-xs">Doc_checklist.xlsx</span>
                                    </div>
                                </td>
                                <td>
                                    <div class="flex items-center gap-2">
                                        <div class="avatar">
                                            <div class="w-6 h-6 rounded-full">
                                                <img src="https://ui-avatars.com/api/?name=Nguyen+Van+A&background=0d9488&color=fff&size=32" alt="Nguyen Van A" />
                                            </div>
                                        </div>
                                        <span class="text-xs">Nguyễn Văn A</span>
                                    </div>
                                </td>
                                <td class="text-center">
                                    <span class="badge badge-success">YES</span>
                                </td>
                                <td class="max-w-xs">
                                    <div class="text-xs">Tất cả giấy tờ đầy đủ và hợp lệ</div>
                                </td>
                                <td>
                                    <div class="flex items-center gap-2">
                                        <div class="avatar">
                                            <div class="w-6 h-6 rounded-full">
                                                <img src="https://ui-avatars.com/api/?name=Tran+Thi+B&background=dc2626&color=fff&size=32" alt="Tran Thi B" />
                                            </div>
                                        </div>
                                        <span class="text-xs">Trần Thị B</span>
                                    </div>
                                </td>
                                <td class="text-center">
                                    <span class="badge badge-success">YES</span>
                                </td>
                                <td class="max-w-xs">
                                    <div class="text-xs">Đã xác nhận với bộ phận pháp lý</div>
                                </td>
                                <td class="max-w-xs">
                                    <div class="text-xs">Cần cập nhật bảo hiểm trong 30 ngày</div>
                                </td>
                            </tr>
                            <tr>
                                <td class="text-center font-mono">02</td>
                                <td class="max-w-xs">
                                    <div class="font-medium">Kiểm tra an toàn thiết bị</div>
                                    <div class="text-xs text-gray-500">Đánh giá tình trạng thiết bị an toàn</div>
                                </td>
                                <td class="max-w-xs">
                                    <div class="text-xs">Kiểm tra áo phao, bè cứu sinh, hệ thống báo cháy</div>
                                </td>
                                <td>
                                    <div class="flex flex-col gap-1">
                                        <span class="badge badge-outline badge-xs">Safety_check.pdf</span>
                                    </div>
                                </td>
                                <td>
                                    <div class="flex items-center gap-2">
                                        <div class="avatar">
                                            <div class="w-6 h-6 rounded-full">
                                                <img src="https://ui-avatars.com/api/?name=Le+Van+C&background=059669&color=fff&size=32" alt="Le Van C" />
                                            </div>
                                        </div>
                                        <span class="text-xs">Lê Văn C</span>
                                    </div>
                                </td>
                                <td class="text-center">
                                    <span class="badge badge-warning">NO</span>
                                </td>
                                <td class="max-w-xs">
                                    <div class="text-xs">Một số áo phao cần thay thế</div>
                                </td>
                                <td>
                                    <div class="flex items-center gap-2">
                                        <div class="avatar">
                                            <div class="w-6 h-6 rounded-full">
                                                <img src="https://ui-avatars.com/api/?name=Pham+Van+D&background=7c3aed&color=fff&size=32" alt="Pham Van D" />
                                            </div>
                                        </div>
                                        <span class="text-xs">Phạm Văn D</span>
                                    </div>
                                </td>
                                <td class="text-center">
                                    <span class="badge badge-warning">NO</span>
                                </td>
                                <td class="max-w-xs">
                                    <div class="text-xs">Đồng ý cần cải thiện thiết bị</div>
                                </td>
                                <td class="max-w-xs">
                                    <div class="text-xs">Ưu tiên cao - cần xử lý ngay</div>
                                </td>
                            </tr>
                            <tr>
                                <td class="text-center font-mono">03</td>
                                <td class="max-w-xs">
                                    <div class="font-medium">Kiểm tra động cơ</div>
                                    <div class="text-xs text-gray-500">Đánh giá hiệu suất và bảo trì động cơ</div>
                                </td>
                                <td class="max-w-xs">
                                    <div class="text-xs">Kiểm tra dầu máy, hệ thống làm mát, tiếng ồn</div>
                                </td>
                                <td>
                                    <div class="flex flex-col gap-1">
                                        <span class="badge badge-outline badge-xs">Engine_report.pdf</span>
                                        <span class="badge badge-outline badge-xs">Maintenance_log.xlsx</span>
                                    </div>
                                </td>
                                <td>
                                    <div class="flex items-center gap-2">
                                        <div class="avatar">
                                            <div class="w-6 h-6 rounded-full">
                                                <img src="https://ui-avatars.com/api/?name=Hoang+Thi+E&background=ea580c&color=fff&size=32" alt="Hoang Thi E" />
                                            </div>
                                        </div>
                                        <span class="text-xs">Hoàng Thị E</span>
                                    </div>
                                </td>
                                <td class="text-center">
                                    <span class="badge badge-success">YES</span>
                                </td>
                                <td class="max-w-xs">
                                    <div class="text-xs">Động cơ hoạt động tốt, đã bảo trì định kỳ</div>
                                </td>
                                <td>
                                    <div class="flex items-center gap-2">
                                        <div class="avatar">
                                            <div class="w-6 h-6 rounded-full">
                                                <img src="https://ui-avatars.com/api/?name=Vu+Van+F&background=1d4ed8&color=fff&size=32" alt="Vu Van F" />
                                            </div>
                                        </div>
                                        <span class="text-xs">Vũ Văn F</span>
                                    </div>
                                </td>
                                <td class="text-center">
                                    <span class="badge badge-success">YES</span>
                                </td>
                                <td class="max-w-xs">
                                    <div class="text-xs">Xác nhận từ bộ phận kỹ thuật</div>
                                </td>
                                <td class="max-w-xs">
                                    <div class="text-xs">Lên lịch bảo trì tiếp theo</div>
                                </td>
                            </tr>
                            <tr>
                                <td class="text-center font-mono">04</td>
                                <td class="max-w-xs">
                                    <div class="font-medium">Kiểm tra hệ thống điện</div>
                                    <div class="text-xs text-gray-500">Đánh giá an toàn hệ thống điện tàu</div>
                                </td>
                                <td class="max-w-xs">
                                    <div class="text-xs">Kiểm tra cầu chì, dây dẫn, thiết bị điện</div>
                                </td>
                                <td>
                                    <div class="flex flex-col gap-1">
                                        <span class="badge badge-outline badge-xs">Electrical_test.pdf</span>
                                    </div>
                                </td>
                                <td>
                                    <div class="flex items-center gap-2">
                                        <div class="avatar">
                                            <div class="w-6 h-6 rounded-full">
                                                <img src="https://ui-avatars.com/api/?name=Dao+Van+G&background=be185d&color=fff&size=32" alt="Dao Van G" />
                                            </div>
                                        </div>
                                        <span class="text-xs">Đào Văn G</span>
                                    </div>
                                </td>
                                <td class="text-center">
                                    <span class="badge badge-neutral">NA</span>
                                </td>
                                <td class="max-w-xs">
                                    <div class="text-xs">Chưa thể kiểm tra do thời tiết</div>
                                </td>
                                <td>
                                    <div class="flex items-center gap-2">
                                        <div class="avatar">
                                            <div class="w-6 h-6 rounded-full">
                                                <img src="https://ui-avatars.com/api/?name=Bui+Thi+H&background=0891b2&color=fff&size=32" alt="Bui Thi H" />
                                            </div>
                                        </div>
                                        <span class="text-xs">Bùi Thị H</span>
                                    </div>
                                </td>
                                <td class="text-center">
                                    <span class="badge badge-neutral">NA</span>
                                </td>
                                <td class="max-w-xs">
                                    <div class="text-xs">Sẽ kiểm tra trong lần tới</div>
                                </td>
                                <td class="max-w-xs">
                                    <div class="text-xs">Lên lịch kiểm tra lại tuần tới</div>
                                </td>
                            </tr>
                            <tr>
                                <td class="text-center font-mono">05</td>
                                <td class="max-w-xs">
                                    <div class="font-medium">Kiểm tra thân vỏ tàu</div>
                                    <div class="text-xs text-gray-500">Đánh giá tình trạng thân vỏ và kết cấu</div>
                                </td>
                                <td class="max-w-xs">
                                    <div class="text-xs">Kiểm tra vết nứt, gỉ sét, độ bền kết cấu</div>
                                </td>
                                <td>
                                    <div class="flex flex-col gap-1">
                                        <span class="badge badge-outline badge-xs">Hull_inspection.pdf</span>
                                        <span class="badge badge-outline badge-xs">Photos.zip</span>
                                    </div>
                                </td>
                                <td>
                                    <div class="flex items-center gap-2">
                                        <div class="avatar">
                                            <div class="w-6 h-6 rounded-full">
                                                <img src="https://ui-avatars.com/api/?name=Mai+Van+I&background=16a34a&color=fff&size=32" alt="Mai Van I" />
                                            </div>
                                        </div>
                                        <span class="text-xs">Mai Văn I</span>
                                    </div>
                                </td>
                                <td class="text-center">
                                    <span class="badge badge-success">YES</span>
                                </td>
                                <td class="max-w-xs">
                                    <div class="text-xs">Thân vỏ tàu trong tình trạng tốt</div>
                                </td>
                                <td>
                                    <div class="flex items-center gap-2">
                                        <div class="avatar">
                                            <div class="w-6 h-6 rounded-full">
                                                <img src="https://ui-avatars.com/api/?name=Ly+Thi+J&background=facc15&color=000&size=32" alt="Ly Thi J" />
                                            </div>
                                        </div>
                                        <span class="text-xs">Lý Thị J</span>
                                    </div>
                                </td>
                                <td class="text-center">
                                    <span class="badge badge-success">YES</span>
                                </td>
                                <td class="max-w-xs">
                                    <div class="text-xs">Đồng ý với đánh giá kỹ thuật</div>
                                </td>
                                <td class="max-w-xs">
                                    <div class="text-xs">Tàu đạt tiêu chuẩn an toàn</div>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <!-- Summary Section -->
                <div class="mt-6 grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div class="stat bg-success/10 rounded-lg">
                        <div class="stat-figure text-success">
                            <i data-lucide="check-circle" class="w-8 h-8"></i>
                        </div>
                        <div class="stat-title text-success">Đạt yêu cầu</div>
                        <div class="stat-value text-success">3</div>
                        <div class="stat-desc">mục kiểm tra</div>
                    </div>
                    
                    <div class="stat bg-warning/10 rounded-lg">
                        <div class="stat-figure text-warning">
                            <i data-lucide="alert-circle" class="w-8 h-8"></i>
                        </div>
                        <div class="stat-title text-warning">Cần cải thiện</div>
                        <div class="stat-value text-warning">1</div>
                        <div class="stat-desc">mục kiểm tra</div>
                    </div>
                    
                    <div class="stat bg-neutral/10 rounded-lg">
                        <div class="stat-figure text-neutral">
                            <i data-lucide="minus-circle" class="w-8 h-8"></i>
                        </div>
                        <div class="stat-title text-neutral">Chưa đánh giá</div>
                        <div class="stat-value text-neutral">1</div>
                        <div class="stat-desc">mục kiểm tra</div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    @raw
    <script>
        function reviewManager() {
            return {
                companies: [],
                ships: [],
                selectedCompanyId: null,
                selectedShipId: null,
                searchQuery: '',
                showSearchBar: false,
                loading: false,
                loadingShips: false,

                async loadCompanies() {
                    try {
                        const response = await fetch('/api/companies?page=0&size=1000');
                        if (response.ok) {
                            const data = await response.json();
                            this.companies = data.content || [];
                        }
                    } catch (error) {
                        console.error('Failed to load companies:', error);
                    }
                },

                async loadShipsByCompany() {
                    if (!this.selectedCompanyId) {
                        this.ships = [];
                        this.selectedShipId = '';
                        this.showSearchBar = false;
                        return;
                    }

                    this.loadingShips = true;
                    this.selectedShipId = '';
                    this.showSearchBar = false;
                    
                    try {
                        const response = await fetch(`/api/ships?page=0&size=1000`);
                        if (response.ok) {
                            const data = await response.json();
                            // Filter ships by company
                            this.ships = (data.content || []).filter(ship => 
                                ship.companyId == this.selectedCompanyId
                            );
                        }
                    } catch (error) {
                        console.error('Failed to load ships:', error);
                        this.ships = [];
                    } finally {
                        this.loadingShips = false;
                    }
                },

                async loadReviews() {
                    if (!this.selectedCompanyId || !this.selectedShipId) {
                        return;
                    }

                    this.loading = true;
                    try {
                        // TODO: Load reviews for selected ship
                        // Simulate loading delay
                        await new Promise(resolve => setTimeout(resolve, 1000));
                        
                        // Show search bar after successful load
                        this.showSearchBar = true;
                    } catch (error) {
                        console.error('Failed to load reviews:', error);
                    } finally {
                        this.loading = false;
                        this.$nextTick(() => lucide.createIcons());
                    }
                },

                searchReviews() {
                    // TODO: Implement search functionality
                    console.log('Searching for:', this.searchQuery);
                }
            }
        }
    </script>
    @endraw
`
)