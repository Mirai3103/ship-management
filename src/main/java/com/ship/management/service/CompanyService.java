package com.ship.management.service;

import com.ship.management.dto.CompanyDTO;
import com.ship.management.entity.Company;
import com.ship.management.entity.Role.RootRole;
import com.ship.management.repository.CompanyRepository;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;

import org.modelmapper.ModelMapper;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Objects;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class CompanyService {

    private final CompanyRepository companyRepository;
    private final ModelMapper modelMapper;
    private final UserService userService;

    public Page<CompanyDTO> getAllCompanies(Pageable pageable) {

        Page<Company> companies = companyRepository.findAllByOrderByOrderNoDesc(pageable);
        return companies.map(this::convertToDTO);

    }

    public Page<CompanyDTO> getAllCompaniesStrict(Pageable pageable) {
        var rootRole = userService.getCurrentUserRootRole();
        if (rootRole == RootRole.ADMIN) {
            Page<Company> companies = companyRepository.findAll(pageable);
            return companies.map(this::convertToDTO);
        }
        var currentUser = userService.getCurrentUser();
        var userCompany = currentUser.getCompany();
        return new PageImpl<>(List.of(convertToDTO(userCompany)), pageable, 1);
    }

    public Optional<CompanyDTO> getCompanyById(Long id) {
        return companyRepository.findById(id)
                .map(this::convertToDTO);
    }

    public Optional<CompanyDTO> getCompanyByName(String name) {
        return companyRepository.findByName(name)
                .map(this::convertToDTO);
    }

    public Optional<CompanyDTO> getCompanyByEmail(String email) {
        return companyRepository.findByEmail(email)
                .map(this::convertToDTO);
    }

    public CompanyDTO createCompany(CompanyDTO companyDTO) {
        Company company = convertToEntity(companyDTO);
        company.setId(null); // Ensure it's a new entity
        Company savedCompany = companyRepository.save(company);
        this.updateCompanyOrderNo(savedCompany.getId(), 999);
        return convertToDTO(savedCompany);
    }

    public Optional<CompanyDTO> updateCompany(Long id, CompanyDTO companyDTO) {
        return companyRepository.findById(id)
                .map(existingCompany -> {
                    existingCompany.setName(companyDTO.getName());
                    existingCompany.setAddress(companyDTO.getAddress());
                    existingCompany.setPhone(companyDTO.getPhone());
                    existingCompany.setEmail(companyDTO.getEmail());
                    Company updatedCompany = companyRepository.save(existingCompany);
                    return convertToDTO(updatedCompany);
                });
    }

    public boolean deleteCompany(Long id) {
        if (companyRepository.existsById(id)) {
            companyRepository.deleteById(id);
            return true;
        }
        return false;
    }

    private CompanyDTO convertToDTO(Company company) {
        return modelMapper.map(company, CompanyDTO.class);
    }

    private Company convertToEntity(CompanyDTO companyDTO) {
        return modelMapper.map(companyDTO, Company.class);
    }

 


    @Transactional
    public void updateCompanyOrderNo(Long id, Integer orderNo) {
        // Lấy toàn bộ companies theo thứ tự
        var allCompanies = companyRepository.findAllByOrderByOrderNoAsc();
        allCompanies.stream().forEach(company -> company.setOrderNo(Objects.isNull(company.getOrderNo()) ? 0 : company.getOrderNo()));
        
        // Tìm company cần thay đổi
        var company = allCompanies.stream()
                .filter(item -> item.getId().equals(id))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Company not found"));
    
        int currentOrder = Objects.isNull(company.getOrderNo()) ? 0 : company.getOrderNo();
        int newOrder = orderNo;
    
        // Giới hạn newOrder hợp lý
        if (newOrder < 1) newOrder = 1;
        if (newOrder > allCompanies.size()) newOrder = allCompanies.size();
    
        if (newOrder == currentOrder) return; // Không cần xử lý nếu không thay đổi
    
        for (var item : allCompanies) {
            // Di chuyển lên trên danh sách
            if (newOrder < currentOrder) {
                if (item.getOrderNo() >= newOrder && item.getOrderNo() < currentOrder) {
                    item.setOrderNo(item.getOrderNo() + 1);
                }
            }
            // Di chuyển xuống dưới danh sách
            else {
                if (item.getOrderNo() <= newOrder && item.getOrderNo() > currentOrder) {
                    item.setOrderNo(item.getOrderNo() - 1);
                }
            }
        }
    
        // Cập nhật order cho company cần di chuyển
        company.setOrderNo(newOrder);
    
        // Lưu toàn bộ danh sách (có thể tối ưu chỉ lưu những item thực sự thay đổi)
        // then re generate orderNo for all items start from 1
        Collections.sort(allCompanies, Comparator.comparingInt(Company::getOrderNo));
        for(int i = 0; i < allCompanies.size(); i++){
            allCompanies.get(i).setOrderNo(i+1);
        }
        companyRepository.saveAll(allCompanies);
    }
}