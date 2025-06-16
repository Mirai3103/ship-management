package com.ship.management.seeder;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import com.github.javafaker.Faker;
import com.ship.management.entity.ChecklistTemplate;
import com.ship.management.entity.Company;
import com.ship.management.entity.Role;
import com.ship.management.entity.Ship;
import com.ship.management.entity.User;
import com.ship.management.repository.ChecklistTemplateRepository;
import com.ship.management.repository.CompanyRepository;
import com.ship.management.repository.RoleRepository;
import com.ship.management.repository.ShipRepository;
import com.ship.management.repository.UserRepository;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class DataSeeder {
    private final RoleRepository roleRepository;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final CompanyRepository companyRepository;
    private final ShipRepository shipRepository;
    private final ChecklistTemplateRepository checklistTemplateRepository;

    @EventListener(ApplicationReadyEvent.class)
    public void seedData() {
        if (roleRepository.count() == 0) {

            Role admin = Role.builder()
                    .name("ADMIN")
                    .description("Administrator")
                    .rootRole(Role.RootRole.ADMIN)
                    .build();
            Role cap = Role.builder()
                    .name("CAP")
                    .description("Captain")
                    .rootRole(Role.RootRole.SHIP)
                    .build();
     
            Role tec = Role.builder()
                    .name("TEC")
                    .description("Technical")
                    .rootRole(Role.RootRole.COMPANY)
                    .build();
            Role com = Role.builder()
                    .name("COM")
                    .description("Communication")
                    .rootRole(Role.RootRole.SHIP)
                    .build();
            Role user = Role.builder()
                    .name("C/O")
                    .description("C/O")
                    .rootRole(Role.RootRole.COMPANY)
                    .build();
            Role cez = Role.builder()
                    .name("C/E")
                    .description("Chief Engineer")
                    .rootRole(Role.RootRole.COMPANY)
                    .build();

            roleRepository.saveAll(List.of(admin, cap, tec, com, user, cez));
        }
        if (companyRepository.count() == 0) {
            Company fml = Company.builder()
                    .name("Fleet Management Limited (FML)")
                    .address("Hồng Kông / Toàn cầu")
                    .phone("0909090909")
                    .email("fml@gmail.com")
                    .build();
            Company csm = Company.builder()
                    .name("Columbia Shipmanagement (CSM)")
                    .address("Đức / Toàn cầu")
                    .phone("0909090909")
                    .email("csm@gmail.com")
                    .build();
            Company vimc = Company.builder()
                    .name("VIMC (Tổng công ty Hàng hải Việt Nam)")
                    .address("Việt Nam")
                    .phone("0909090909")
                    .email("vimc@gmail.com")
                    .build();
            Company gemadept = Company.builder()
                    .name("Gemadept Shipping")
                    .address("Việt Nam")
                    .phone("0909090909")
                    .email("gemadept@gmail.com")
                    .build();
            companyRepository.saveAll(List.of(fml, csm, vimc, gemadept));

        }
        Faker faker = new Faker(Locale.ENGLISH);
        List<Role> allRoles = roleRepository.findAll().stream().filter(role -> role.getRootRole() != Role.RootRole.ADMIN)
                .toList();
        if (userRepository.count() == 0) {
            User admin = User.builder()
                    .email("admin@gmail.com")
                    .fullName("Admin")
                    .hashedPassword(passwordEncoder.encode("admin"))
                    .role(roleRepository.findByName("ADMIN").orElseThrow())
                    .build();
            userRepository.save(admin);

            for (Company company : companyRepository.findAll()) {
                var numberOfUsers = faker.number().numberBetween(1, 10);
                for (int i = 0; i < numberOfUsers; i++) {
                    User user = User.builder()
                            .email(faker.internet().emailAddress())
                            .fullName(faker.name().fullName())
                            .hashedPassword(passwordEncoder.encode("123456"))
                            .role(allRoles.get(faker.number().numberBetween(0, allRoles.size() - 1)))
                            .company(company)
                            .build();
                    userRepository.save(user);
                }
            }
        }
        if(shipRepository.count() == 0) {
            for(Company company : companyRepository.findAll()) {
                var userOfCompany = userRepository.findByCompanyId(company.getId());
                var numberOfShips = faker.number().numberBetween(1, 3);
                for(int i = 0; i < numberOfShips; i++) {
                    Ship ship = Ship.builder()
                    .name(faker.funnyName().name())
                    .description(faker.lorem().sentence())
                    .users(new ArrayList<User>())
                    .company(company).build();

                    var numberOfUsers = faker.number().numberBetween(1, userOfCompany.size());
                    for(int j = 0; j < numberOfUsers; j++) {
                        User user = userOfCompany.get(faker.number().numberBetween(0, userOfCompany.size() - 1));
                        ship.getUsers().add(user);
                    }
                    shipRepository.save(ship);
                }
            }
        }
      
    }
}
