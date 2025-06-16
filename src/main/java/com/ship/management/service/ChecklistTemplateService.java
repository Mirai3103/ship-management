package com.ship.management.service;

import com.ship.management.dto.ChecklistItemDTO;
import com.ship.management.dto.ChecklistTemplateDTO;
import com.ship.management.entity.ChecklistTemplate;
import com.ship.management.entity.Company;
import com.ship.management.entity.Ship;
import com.ship.management.entity.ReviewPlan;
import com.ship.management.entity.Role;
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
import java.util.stream.Stream;

@Service
@RequiredArgsConstructor
public class ChecklistTemplateService {

    private final ChecklistTemplateRepository checklistTemplateRepository;
    private final ShipRepository shipRepository;
    private final CompanyRepository companyRepository;
    private final ModelMapper modelMapper;
    private final UserService userService;

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
        return handlePermission( checklistTemplateRepository.findByShipIdOrderByOrderNoAsc(shipId)
        .stream()
        .map(this::convertToDTO)
        .toList());
    }

    public List<ChecklistTemplateDTO> handlePermission(List<ChecklistTemplateDTO> templates) {
        var currentUser = userService.getCurrentUser();
        var permissions = currentUser.getListAuthorities();
        if(Stream.of("ROLE_ADMIN","REVIEW_MANAGEMENT").anyMatch(permissions::contains)) {
            return templates;
        }
        return templates.stream() 
        .peek(t->{
            var listCheckList = t.getChecklistItems();
            if(listCheckList!=null){
                listCheckList=  listCheckList.stream().filter(
                    item->List.of(item.getAssignedToId(), item.getComAssignedToId()).contains(currentUser.getId())
                ).toList();
            }
            t.setChecklistItems(listCheckList);
        }).filter(t-> !t.getChecklistItems().isEmpty()).toList();
    }



    public ChecklistTemplateDTO createChecklistTemplate(ChecklistTemplateDTO templateDTO) throws Exception {

        Ship ship = shipRepository.findById(templateDTO.getShipId())
                .orElseThrow(() -> new Exception("Tàu không tồn tại"));


        Company company = companyRepository.findById(templateDTO.getCompanyId())
                .orElseThrow(() -> new Exception("Công ty không tồn tại"));


        if (checklistTemplateRepository.existsBySectionAndShipId(templateDTO.getSection(), templateDTO.getShipId())) {
            throw new Exception("Phần kiểm tra đã tồn tại cho tàu này");
        }


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

                    if (!existingTemplate.getSection().equals(templateDTO.getSection()) &&
                        checklistTemplateRepository.existsBySectionAndShipId(templateDTO.getSection(), existingTemplate.getShip().getId())) {
                        throw new RuntimeException("Phần kiểm tra đã tồn tại cho tàu này");
                    }


                    existingTemplate.setSection(templateDTO.getSection());
                    existingTemplate.setOrderNo(templateDTO.getOrderNo());


                    if (!existingTemplate.getShip().getId().equals(templateDTO.getShipId())) {
                        Ship ship = shipRepository.findById(templateDTO.getShipId())
                                .orElseThrow(() -> new RuntimeException("Tàu không tồn tại"));
                        existingTemplate.setShip(ship);
                    }


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


        }
        if(template.getChecklistItems()!=null){
            dto.setChecklistItems(template.getChecklistItems().stream().map(item->modelMapper.map(item, ChecklistItemDTO.class)).toList());
        }
        

        if (template.getChecklistItems() != null) {
            dto.setItemCount(template.getChecklistItems().size());
        }
        
        return dto;
    }

    private ChecklistTemplate convertToEntity(ChecklistTemplateDTO dto) {
        return modelMapper.map(dto, ChecklistTemplate.class);
    }
} 