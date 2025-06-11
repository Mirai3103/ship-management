@template.layout(
    title = "Tổng quan",
    activePage = "dashboard",
    content = @`
        <!-- Dashboard Overview -->
        <div class="space-y-6">
            <!-- Welcome Section -->
            <div class="bg-gradient-to-r from-primary to-secondary rounded-lg p-6 text-primary-content">
                <div class="flex items-center justify-between">
                    <div>
                        <h1 class="text-2xl font-bold">Chào mừng trở lại!</h1>
                        <p class="text-primary-content/80">Hôm nay có 12 tàu đang hoạt động và 3 tàu đang bảo trì</p>
                    </div>
                    <div class="hidden md:block">
                        <i data-lucide="ship" class="w-16 h-16 opacity-20"></i>
                    </div>
                </div>
            </div>

            <!-- Key Metrics -->
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                <!-- Total Ships -->
                <div class="stats shadow">
                    <div class="stat">
                        <div class="stat-figure text-primary">
                            <i data-lucide="ship" class="w-8 h-8"></i>
                        </div>
                        <div class="stat-title">Tổng số tàu</div>
                        <div class="stat-value text-primary">24</div>
                        <div class="stat-desc">↗︎ 2 tàu mới trong tháng</div>
                    </div>
                </div>

                <!-- Active Voyages -->
                <div class="stats shadow">
                    <div class="stat">
                        <div class="stat-figure text-secondary">
                            <i data-lucide="navigation" class="w-8 h-8"></i>
                        </div>
                        <div class="stat-title">Chuyến đi</div>
                        <div class="stat-value text-secondary">89</div>
                        <div class="stat-desc">↗︎ 12% so với tháng trước</div>
                    </div>
                </div>

                <!-- Total Crew -->
                <div class="stats shadow">
                    <div class="stat">
                        <div class="stat-figure text-accent">
                            <i data-lucide="users" class="w-8 h-8"></i>
                        </div>
                        <div class="stat-title">Thủy thủ đoàn</div>
                        <div class="stat-value text-accent">156</div>
                        <div class="stat-desc">↘︎ 3 người nghỉ phép</div>
                    </div>
                </div>

                <!-- Revenue -->
                <div class="stats shadow">
                    <div class="stat">
                        <div class="stat-figure text-success">
                            <i data-lucide="dollar-sign" class="w-8 h-8"></i>
                        </div>
                        <div class="stat-title">Doanh thu</div>
                        <div class="stat-value text-success">$2.4M</div>
                        <div class="stat-desc">↗︎ 8% so với tháng trước</div>
                    </div>
                </div>
            </div>

            <!-- Charts and Tables Row -->
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <!-- Fleet Status Chart -->
                <div class="col-span-2 card bg-base-100 shadow-xl">
                    <div class="card-body">
                        <h2 class="card-title">
                            <i data-lucide="bar-chart-3" class="w-5 h-5"></i>
                            Trạng thái đội tàu
                        </h2>
                        <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mt-4">
                            <div class="text-center">
                                <div class="radial-progress text-success" style="--value:75;" role="progressbar">75%</div>
                                <div class="text-sm mt-2">Hoạt động</div>
                                <div class="text-xs text-base-content/70">18 tàu</div>
                            </div>
                            <div class="text-center">
                                <div class="radial-progress text-warning" style="--value:15;" role="progressbar">15%</div>
                                <div class="text-sm mt-2">Bảo trì</div>
                                <div class="text-xs text-base-content/70">3 tàu</div>
                            </div>
                            <div class="text-center">
                                <div class="radial-progress text-info" style="--value:8;" role="progressbar">8%</div>
                                <div class="text-sm mt-2">Chờ lệnh</div>
                                <div class="text-xs text-base-content/70">2 tàu</div>
                            </div>
                            <div class="text-center">
                                <div class="radial-progress text-error" style="--value:2;" role="progressbar">2%</div>
                                <div class="text-sm mt-2">Sự cố</div>
                                <div class="text-xs text-base-content/70">1 tàu</div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Quick Actions -->
                <div class="card bg-base-100 shadow-xl">
                    <div class="card-body">
                        <h2 class="card-title">
                            <i data-lucide="zap" class="w-5 h-5"></i>
                            Thao tác nhanh
                        </h2>
                        <div class="space-y-3 mt-4">
                            <button class="btn btn-primary btn-block justify-start">
                                <i data-lucide="plus" class="w-4 h-4"></i>
                                Thêm tàu mới
                            </button>
                            <button class="btn btn-secondary btn-block justify-start">
                                <i data-lucide="calendar-plus" class="w-4 h-4"></i>
                                Lập lịch chuyến đi
                            </button>
                            <button class="btn btn-accent btn-block justify-start">
                                <i data-lucide="user-plus" class="w-4 h-4"></i>
                                Thêm thành viên
                            </button>
                            <button class="btn btn-warning btn-block justify-start">
                                <i data-lucide="wrench" class="w-4 h-4"></i>
                                Lập kế hoạch bảo trì
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Recent Activities and Alerts -->
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <!-- Recent Activities -->
                <div class="card bg-base-100 shadow-xl">
                    <div class="card-body">
                        <h2 class="card-title">
                            <i data-lucide="activity" class="w-5 h-5"></i>
                            Hoạt động gần đây
                        </h2>
                        <div class="space-y-4 mt-4">
                            <div class="flex items-start space-x-3">
                                <div class="w-2 h-2 bg-success rounded-full mt-2"></div>
                                <div class="flex-1">
                                    <p class="text-sm">Tàu <strong>Sea Explorer</strong> đã cập cảng Hồ Chí Minh</p>
                                    <p class="text-xs text-base-content/70">5 phút trước</p>
                                </div>
                            </div>
                            <div class="flex items-start space-x-3">
                                <div class="w-2 h-2 bg-warning rounded-full mt-2"></div>
                                <div class="flex-1">
                                    <p class="text-sm">Bảo trì định kỳ cho tàu <strong>Ocean Star</strong> được lên lịch</p>
                                    <p class="text-xs text-base-content/70">1 giờ trước</p>
                                </div>
                            </div>
                            <div class="flex items-start space-x-3">
                                <div class="w-2 h-2 bg-info rounded-full mt-2"></div>
                                <div class="flex-1">
                                    <p class="text-sm">Thủy thủ <strong>Nguyễn Văn A</strong> đã hoàn thành chứng chỉ an toàn</p>
                                    <p class="text-xs text-base-content/70">2 giờ trước</p>
                                </div>
                            </div>
                            <div class="flex items-start space-x-3">
                                <div class="w-2 h-2 bg-primary rounded-full mt-2"></div>
                                <div class="flex-1">
                                    <p class="text-sm">Tuyến đường mới <strong>HCM - Hải Phòng</strong> được phê duyệt</p>
                                    <p class="text-xs text-base-content/70">3 giờ trước</p>
                                </div>
                            </div>
                        </div>
                        <div class="card-actions justify-end mt-4">
                            <button class="btn btn-ghost btn-sm">Xem tất cả</button>
                        </div>
                    </div>
                </div>

                <!-- Alerts and Notifications -->
                <div class="card bg-base-100 shadow-xl">
                    <div class="card-body">
                        <h2 class="card-title">
                            <i data-lucide="alert-triangle" class="w-5 h-5"></i>
                            Cảnh báo & Thông báo
                        </h2>
                        <div class="space-y-3 mt-4">
                            <div class="alert alert-warning">
                                <i data-lucide="alert-triangle" class="w-4 h-4"></i>
                                <div>
                                    <div class="font-medium">Bảo trì khẩn cấp</div>
                                    <div class="text-sm">Tàu ABC123 cần bảo trì động cơ</div>
                                </div>
                            </div>
                            <div class="alert alert-info">
                                <i data-lucide="info" class="w-4 h-4"></i>
                                <div>
                                    <div class="font-medium">Thời tiết</div>
                                    <div class="text-sm">Bão nhiệt đới cấp 3 gần khu vực vịnh Bắc Bộ</div>
                                </div>
                            </div>
                            <div class="alert alert-success">
                                <i data-lucide="check-circle" class="w-4 h-4"></i>
                                <div>
                                    <div class="font-medium">Kiểm tra an toàn</div>
                                    <div class="text-sm">5 tàu đã hoàn thành kiểm tra an toàn định kỳ</div>
                                </div>
                            </div>
                        </div>
                        <div class="card-actions justify-end mt-4">
                            <button class="btn btn-ghost btn-sm">Quản lý cảnh báo</button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Ships Currently at Sea -->
            <div class="card bg-base-100 shadow-xl">
                <div class="card-body">
                    <h2 class="card-title">
                        <i data-lucide="waves" class="w-5 h-5"></i>
                        Tàu đang hoạt động
                    </h2>
                    <div class="overflow-x-auto mt-4">
                        <table class="table table-zebra w-full">
                            <thead>
                                <tr>
                                    <th>Tên tàu</th>
                                    <th>Vị trí hiện tại</th>
                                    <th>Điểm đến</th>
                                    <th>ETA</th>
                                    <th>Trạng thái</th>
                                    <th>Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>
                                        <div class="flex items-center space-x-3">
                                            <div class="w-3 h-3 bg-success rounded-full"></div>
                                            <span class="font-medium">Sea Explorer</span>
                                        </div>
                                    </td>
                                    <td>15°N, 109°E</td>
                                    <td>Cảng Hồ Chí Minh</td>
                                    <td>14:30 hôm nay</td>
                                    <td><span class="badge badge-success">Đang di chuyển</span></td>
                                    <td>
                                        <button class="btn btn-ghost btn-xs">
                                            <i data-lucide="eye" class="w-3 h-3"></i>
                                        </button>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <div class="flex items-center space-x-3">
                                            <div class="w-3 h-3 bg-warning rounded-full"></div>
                                            <span class="font-medium">Ocean Star</span>
                                        </div>
                                    </td>
                                    <td>Cảng Đà Nẵng</td>
                                    <td>Cảng Hải Phòng</td>
                                    <td>09:00 ngày mai</td>
                                    <td><span class="badge badge-warning">Đang tải hàng</span></td>
                                    <td>
                                        <button class="btn btn-ghost btn-xs">
                                            <i data-lucide="eye" class="w-3 h-3"></i>
                                        </button>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <div class="flex items-center space-x-3">
                                            <div class="w-3 h-3 bg-info rounded-full"></div>
                                            <span class="font-medium">Blue Wave</span>
                                        </div>
                                    </td>
                                    <td>12°N, 107°E</td>
                                    <td>Cảng Cần Thơ</td>
                                    <td>16:00 ngày mai</td>
                                    <td><span class="badge badge-info">Đang di chuyển</span></td>
                                    <td>
                                        <button class="btn btn-ghost btn-xs">
                                            <i data-lucide="eye" class="w-3 h-3"></i>
                                        </button>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <div class="card-actions justify-end mt-4">
                        <button class="btn btn-primary btn-sm">Xem tất cả tàu</button>
                    </div>
                </div>
            </div>
        </div>
    `
) 