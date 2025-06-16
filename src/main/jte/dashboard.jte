@import com.ship.management.entity.User

@param User currentUser

@template.layout(
    title = "Tổng quan",
    activePage = "dashboard",
    currentUser = currentUser,
    content = @`
                <div class="space-y-6">
                        <div class="bg-gradient-to-r from-primary to-secondary rounded-lg p-6 text-primary-content">
                <div class="flex items-center justify-between">
                    <div>
                        <h1 class="text-2xl font-bold">Chào mừng trở lại, ${currentUser.getFullName()}!</h1>
                    </div>
                    <div class="hidden md:block">
                        <i data-lucide="ship" class="w-16 h-16 opacity-20"></i>
                    </div>
                </div>
            </div>

        </div>
    `
) 