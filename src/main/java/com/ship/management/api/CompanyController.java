package com.ship.management.api;

import com.ship.management.dto.CompanyDTO;
import com.ship.management.service.CompanyService;
import lombok.RequiredArgsConstructor;

import java.util.Map;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.data.web.PagedModel;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/companies")
@RequiredArgsConstructor
public class CompanyController {

    private final CompanyService companyService;

    @GetMapping
    public ResponseEntity<PagedModel<CompanyDTO>> getAllCompanies(
            @PageableDefault(size = 10, sort = "id") Pageable pageable,
            @RequestParam(required = false, defaultValue = "false") Boolean strict) {
        Page<CompanyDTO> companies = strict ? companyService.getAllCompaniesStrict(pageable) : companyService.getAllCompanies(pageable);
        return ResponseEntity.ok(new PagedModel<>(companies));
    }

    @GetMapping("/{id}")
    public ResponseEntity<CompanyDTO> getCompanyById(@PathVariable Long id) {
        return companyService.getCompanyById(id)
                .map(company -> ResponseEntity.ok(company))
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/name/{name}")
    public ResponseEntity<CompanyDTO> getCompanyByName(@PathVariable String name) {
        return companyService.getCompanyByName(name)
                .map(company -> ResponseEntity.ok(company))
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/email/{email}")
    public ResponseEntity<CompanyDTO> getCompanyByEmail(@PathVariable String email) {
        return companyService.getCompanyByEmail(email)
                .map(company -> ResponseEntity.ok(company))
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<CompanyDTO> createCompany(@Valid @RequestBody CompanyDTO companyDTO) {
        CompanyDTO createdCompany = companyService.createCompany(companyDTO);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdCompany);
    }

    @PutMapping("/{id}")
    public ResponseEntity<CompanyDTO> updateCompany(@PathVariable Long id, 
                                                   @Valid @RequestBody CompanyDTO companyDTO) {
        return companyService.updateCompany(id, companyDTO)
                .map(company -> ResponseEntity.ok(company))
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCompany(@PathVariable Long id) {
        if (companyService.deleteCompany(id)) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }

    @PatchMapping("/{id}/order-no")
    public ResponseEntity<Void> updateCompanyOrderNo(@PathVariable Long id, @RequestBody Map<String, Integer> requestBody) {
        companyService.updateCompanyOrderNo(id, requestBody.get("orderNo"));
        return ResponseEntity.noContent().build();
    }
} 