package com.ship.management.api;

import com.ship.management.dto.ChecklistTemplateDTO;
import com.ship.management.service.ChecklistTemplateService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/checklist-templates")
@RequiredArgsConstructor
public class ChecklistTemplateController {

    private final ChecklistTemplateService checklistTemplateService;

    @GetMapping
    public ResponseEntity<Page<ChecklistTemplateDTO>> getAllChecklistTemplates(
            @PageableDefault(size = 10, sort = "orderNo") Pageable pageable) {
        Page<ChecklistTemplateDTO> templates = checklistTemplateService.getAllChecklistTemplates(pageable);
        return ResponseEntity.ok(templates);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ChecklistTemplateDTO> getChecklistTemplateById(@PathVariable Long id) {
        return checklistTemplateService.getChecklistTemplateById(id)
                .map(template -> ResponseEntity.ok(template))
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/ship/{shipId}")
    public ResponseEntity<Page<ChecklistTemplateDTO>> getChecklistTemplatesByShip(
            @PathVariable Long shipId,
            @PageableDefault(size = 10, sort = "orderNo") Pageable pageable) {
        Page<ChecklistTemplateDTO> templates = checklistTemplateService.getChecklistTemplatesByShip(shipId, pageable);
        return ResponseEntity.ok(templates);
    }

    @GetMapping("/ship/{shipId}/ordered")
    public ResponseEntity<List<ChecklistTemplateDTO>> getChecklistTemplatesByShipOrdered(
            @PathVariable Long shipId) {
        List<ChecklistTemplateDTO> templates = checklistTemplateService.getChecklistTemplatesByShipOrdered(shipId);
        return ResponseEntity.ok(templates);
    }

    @GetMapping("/company/{companyId}")
    public ResponseEntity<Page<ChecklistTemplateDTO>> getChecklistTemplatesByCompany(
            @PathVariable Long companyId,
            @PageableDefault(size = 10, sort = "orderNo") Pageable pageable) {
        Page<ChecklistTemplateDTO> templates = checklistTemplateService.getChecklistTemplatesByCompany(companyId, pageable);
        return ResponseEntity.ok(templates);
    }

    @GetMapping("/ship/{shipId}/company/{companyId}")
    public ResponseEntity<Page<ChecklistTemplateDTO>> getChecklistTemplatesByShipAndCompany(
            @PathVariable Long shipId,
            @PathVariable Long companyId,
            @PageableDefault(size = 10, sort = "orderNo") Pageable pageable) {
        Page<ChecklistTemplateDTO> templates = checklistTemplateService.getChecklistTemplatesByShipAndCompany(shipId, companyId, pageable);
        return ResponseEntity.ok(templates);
    }

    @GetMapping("/search")
    public ResponseEntity<Page<ChecklistTemplateDTO>> searchChecklistTemplates(
            @RequestParam String section,
            @PageableDefault(size = 10, sort = "orderNo") Pageable pageable) {
        Page<ChecklistTemplateDTO> templates = checklistTemplateService.searchChecklistTemplates(section, pageable);
        return ResponseEntity.ok(templates);
    }

    @PostMapping
    public ResponseEntity<?> createChecklistTemplate(@Valid @RequestBody ChecklistTemplateDTO templateDTO) {
        try {
            ChecklistTemplateDTO createdTemplate = checklistTemplateService.createChecklistTemplate(templateDTO);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Tạo template checklist thành công");
            response.put("template", createdTemplate);
            
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ErrorResponse("error", e.getMessage()));
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateChecklistTemplate(@PathVariable Long id, 
                                                    @Valid @RequestBody ChecklistTemplateDTO templateDTO) {
        try {
            return checklistTemplateService.updateChecklistTemplate(id, templateDTO)
                    .map(template -> {
                        Map<String, Object> response = new HashMap<>();
                        response.put("success", true);
                        response.put("message", "Cập nhật template checklist thành công");
                        response.put("template", template);
                        return ResponseEntity.ok(response);
                    })
                    .orElse(ResponseEntity.notFound().build());
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ErrorResponse("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("error", "Lỗi hệ thống"));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteChecklistTemplate(@PathVariable Long id) {
        try {
            if (checklistTemplateService.deleteChecklistTemplate(id)) {
                Map<String, Object> response = new HashMap<>();
                response.put("success", true);
                response.put("message", "Xóa template checklist thành công");
                return ResponseEntity.ok(response);
            }
            return ResponseEntity.notFound().build();
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ErrorResponse("error", e.getMessage()));
        }
    }

    @GetMapping("/ship/{shipId}/count")
    public ResponseEntity<Map<String, Object>> countChecklistTemplatesByShip(@PathVariable Long shipId) {
        long count = checklistTemplateService.countChecklistTemplatesByShip(shipId);
        
        Map<String, Object> response = new HashMap<>();
        response.put("shipId", shipId);
        response.put("count", count);
        
        return ResponseEntity.ok(response);
    }

    // Error response class
    public static class ErrorResponse {
        public String status;
        public String message;

        public ErrorResponse(String status, String message) {
            this.status = status;
            this.message = message;
        }
    }
} 