package com.ship.management.service;

import com.ship.management.dto.CompanyDTO;
import com.ship.management.entity.Company;
import com.ship.management.entity.Role.RootRole;
import com.ship.management.repository.CompanyRepository;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class CompanyService {

    private final CompanyRepository companyRepository;
    private final ModelMapper modelMapper;
    private final UserService userService;

    public Page<CompanyDTO> getAllCompanies(Pageable pageable) {
        var rootRole = userService.getCurrentUserRootRole();
        if(rootRole == RootRole.ADMIN){
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
} 