package com.ship.management.service;

import com.ship.management.dto.ChecklistTemplateDTO;
import com.ship.management.entity.ChecklistTemplate;
import com.ship.management.entity.Company;
import com.ship.management.entity.Ship;
import com.ship.management.entity.ReviewPlan;
import com.ship.management.repository.ChecklistTemplateRepository;
import com.ship.management.repository.CompanyRepository;
import com.ship.management.repository.ShipRepository;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ChecklistTemplateService {

    private final ChecklistTemplateRepository checklistTemplateRepository;
    private final ShipRepository shipRepository;
    private final CompanyRepository companyRepository;
    private final ModelMapper modelMapper;

    public Page<ChecklistTemplateDTO> getAllChecklistTemplates(Pageable pageable) {
        Page<ChecklistTemplate> templates = checklistTemplateRepository.findAll(pageable);
        return templates.map(this::convertToDTO);
    }

    public Optional<ChecklistTemplateDTO> getChecklistTemplateById(Long id) {
        return checklistTemplateRepository.findById(id)
                .map(this::convertToDTO);
    }

    public Page<ChecklistTemplateDTO> getChecklistTemplatesByShip(Long shipId, Pageable pageable) {
        return checklistTemplateRepository.findByShipId(shipId, pageable)
                .map(this::convertToDTO);
    }

    public Page<ChecklistTemplateDTO> getChecklistTemplatesByCompany(Long companyId, Pageable pageable) {
        return checklistTemplateRepository.findByCompanyId(companyId, pageable)
                .map(this::convertToDTO);
    }

    public Page<ChecklistTemplateDTO> getChecklistTemplatesByShipAndCompany(Long shipId, Long companyId, Pageable pageable) {
        return checklistTemplateRepository.findByShipIdAndCompanyId(shipId, companyId, pageable)
                .map(this::convertToDTO);
    }

    public Page<ChecklistTemplateDTO> searchChecklistTemplates(String section, Pageable pageable) {
        return checklistTemplateRepository.findBySectionContainingIgnoreCase(section, pageable)
                .map(this::convertToDTO);
    }

    public List<ChecklistTemplateDTO> getChecklistTemplatesByShipOrdered(Long shipId) {
        return checklistTemplateRepository.findByShipIdOrderByOrderNoAsc(shipId)
                .stream()
                .map(this::convertToDTO)
                .toList();
    }

    public ChecklistTemplateDTO createChecklistTemplate(ChecklistTemplateDTO templateDTO) throws Exception {
        // Validate ship exists
        Ship ship = shipRepository.findById(templateDTO.getShipId())
                .orElseThrow(() -> new Exception("Tàu không tồn tại"));

        // Validate company exists
        Company company = companyRepository.findById(templateDTO.getCompanyId())
                .orElseThrow(() -> new Exception("Công ty không tồn tại"));

        // Check if section already exists for this ship
        if (checklistTemplateRepository.existsBySectionAndShipId(templateDTO.getSection(), templateDTO.getShipId())) {
            throw new Exception("Phần kiểm tra đã tồn tại cho tàu này");
        }

        // Create new template
        ChecklistTemplate template = convertToEntity(templateDTO);
        template.setId(null); // Ensure it's a new entity
        template.setShip(ship);
        template.setCompany(company);

        ChecklistTemplate savedTemplate = checklistTemplateRepository.save(template);
        return convertToDTO(savedTemplate);
    }

    public Optional<ChecklistTemplateDTO> updateChecklistTemplate(Long id, ChecklistTemplateDTO templateDTO) throws Exception {
        return checklistTemplateRepository.findById(id)
                .map(existingTemplate -> {
                    // Check if the new section conflicts with another template for the same ship
                    if (!existingTemplate.getSection().equals(templateDTO.getSection()) &&
                        checklistTemplateRepository.existsBySectionAndShipId(templateDTO.getSection(), existingTemplate.getShip().getId())) {
                        throw new RuntimeException("Phần kiểm tra đã tồn tại cho tàu này");
                    }

                    // Update basic fields
                    existingTemplate.setSection(templateDTO.getSection());
                    existingTemplate.setOrderNo(templateDTO.getOrderNo());

                    // Update ship if changed
                    if (!existingTemplate.getShip().getId().equals(templateDTO.getShipId())) {
                        Ship ship = shipRepository.findById(templateDTO.getShipId())
                                .orElseThrow(() -> new RuntimeException("Tàu không tồn tại"));
                        existingTemplate.setShip(ship);
                    }

                    // Update company if changed
                    if (!existingTemplate.getCompany().getId().equals(templateDTO.getCompanyId())) {
                        Company company = companyRepository.findById(templateDTO.getCompanyId())
                                .orElseThrow(() -> new RuntimeException("Công ty không tồn tại"));
                        existingTemplate.setCompany(company);
                    }

                    ChecklistTemplate updatedTemplate = checklistTemplateRepository.save(existingTemplate);
                    return convertToDTO(updatedTemplate);
                });
    }

    public boolean deleteChecklistTemplate(Long id) {
        if (checklistTemplateRepository.existsById(id)) {
            // Get template with items to check if it has checklist items
            Optional<ChecklistTemplate> template = checklistTemplateRepository.findByIdWithItems(id);
            if (template.isPresent() && template.get().getChecklistItems() != null && 
                !template.get().getChecklistItems().isEmpty()) {
                throw new RuntimeException("Không thể xóa template đang có checklist items");
            }
            
            checklistTemplateRepository.deleteById(id);
            return true;
        }
        return false;
    }

    public long countChecklistTemplatesByShip(Long shipId) {
        return checklistTemplateRepository.countByShipId(shipId);
    }

    private ChecklistTemplateDTO convertToDTO(ChecklistTemplate template) {
        ChecklistTemplateDTO dto = modelMapper.map(template, ChecklistTemplateDTO.class);
        
        // Set related entity IDs and names
        if (template.getShip() != null) {
            dto.setShipId(template.getShip().getId());
            dto.setShipName(template.getShip().getName());
        }
        
        if (template.getCompany() != null) {
            dto.setCompanyId(template.getCompany().getId());
            dto.setCompanyName(template.getCompany().getName());
        }
        
        if (template.getReviewPlan() != null) {
            dto.setReviewPlanId(template.getReviewPlan().getId());
            // Assuming ReviewPlan has a name field - adjust if different
            // dto.setReviewPlanName(template.getReviewPlan().getName());
        }
        
        // Set item count
        if (template.getChecklistItems() != null) {
            dto.setItemCount(template.getChecklistItems().size());
        }
        
        return dto;
    }

    private ChecklistTemplate convertToEntity(ChecklistTemplateDTO dto) {
        return modelMapper.map(dto, ChecklistTemplate.class);
    }
} 