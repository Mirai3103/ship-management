package com.ship.management.api;

import com.ship.management.dto.AttachmentDTO;
import com.ship.management.service.AttachmentService;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.Resource;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import jakarta.validation.Valid;
import java.io.IOException;
import java.net.MalformedURLException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/attachments")
@RequiredArgsConstructor
public class AttachmentController {

    private final AttachmentService attachmentService;

    @GetMapping
    public ResponseEntity<Page<AttachmentDTO>> getAllAttachments(
            @PageableDefault(size = 10, sort = "uploadedAt") Pageable pageable) {
        Page<AttachmentDTO> attachments = attachmentService.getAllAttachments(pageable);
        return ResponseEntity.ok(attachments);
    }

    @GetMapping("/{id}")
    public ResponseEntity<AttachmentDTO> getAttachmentById(@PathVariable Long id) {
        return attachmentService.getAttachmentById(id)
                .map(attachment -> ResponseEntity.ok(attachment))
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/checklist-item/{checklistItemId}")
    public ResponseEntity<List<AttachmentDTO>> getAttachmentsByChecklistItemId(
            @PathVariable Long checklistItemId) {
        List<AttachmentDTO> attachments = attachmentService.getAttachmentsByChecklistItemId(checklistItemId);
        return ResponseEntity.ok(attachments);
    }

    @PostMapping("/upload/single")
    public ResponseEntity<Map<String, Object>> uploadSingleFile(
            @RequestParam("file") MultipartFile file,
            @RequestParam("checklistItemId") Long checklistItemId,
            @RequestParam("uploadedById") Long uploadedById) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            AttachmentDTO attachment = attachmentService.uploadSingleFile(file, checklistItemId, uploadedById);
            response.put("success", true);
            response.put("message", "File đã được tải lên thành công");
            response.put("data", attachment);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (IOException e) {
            response.put("success", false);
            response.put("message", "Lỗi khi tải file: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        } catch (RuntimeException e) {
            response.put("success", false);
            response.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
        }
    }

    @PostMapping("/upload/multiple")
    public ResponseEntity<Map<String, Object>> uploadMultipleFiles(
            @RequestParam("files") MultipartFile[] files,
            @RequestParam("checklistItemId") Long checklistItemId,
            @RequestParam("uploadedById") Long uploadedById) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            List<AttachmentDTO> attachments = attachmentService.uploadMultipleFiles(files, checklistItemId, uploadedById);
            response.put("success", true);
            response.put("message", "Đã tải lên " + attachments.size() + " file thành công");
            response.put("data", attachments);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (IOException e) {
            response.put("success", false);
            response.put("message", "Lỗi khi tải file: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        } catch (RuntimeException e) {
            response.put("success", false);
            response.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
        }
    }

    @GetMapping("/download/{filename}")
    public ResponseEntity<Resource> downloadFile(@PathVariable String filename) {
        try {
            Resource resource = attachmentService.downloadFile(filename);
            String originalFilename = attachmentService.getOriginalFilename(filename);
    
            // Suy đoán content-type từ tên file
            String contentType = Files.probeContentType(Path.of(resource.getFile().getAbsolutePath()));
            if (contentType == null) {
                contentType = "application/octet-stream"; // fallback
            }
    
            return ResponseEntity.ok()
                    .contentType(MediaType.parseMediaType(contentType))
                    // Không ép trình duyệt tải về nếu hỗ trợ
                    .header(HttpHeaders.CONTENT_DISPOSITION, 
                            "inline; filename=\"" + originalFilename + "\"")
                    .body(resource);
        } catch ( IOException e) {
            return ResponseEntity.notFound().build();
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
    

    @PostMapping
    public ResponseEntity<Map<String, Object>> createAttachment(@Valid @RequestBody AttachmentDTO attachmentDTO) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            AttachmentDTO createdAttachment = attachmentService.createAttachment(attachmentDTO);
            response.put("success", true);
            response.put("message", "Đã tạo attachment thành công");
            response.put("data", createdAttachment);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (RuntimeException e) {
            response.put("success", false);
            response.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteAttachment(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();
        
        if (attachmentService.deleteAttachment(id)) {
            response.put("success", true);
            response.put("message", "Đã xóa attachment thành công");
            return ResponseEntity.ok(response);
        } else {
            response.put("success", false);
            response.put("message", "Attachment không tồn tại");
            return ResponseEntity.notFound().build();
        }
    }

    // Additional utility endpoints
    
    @GetMapping("/count/checklist-item/{checklistItemId}")
    public ResponseEntity<Map<String, Object>> countByChecklistItemId(@PathVariable Long checklistItemId) {
        long count = attachmentService.countByChecklistItemId(checklistItemId);
        Map<String, Object> response = new HashMap<>();
        response.put("checklistItemId", checklistItemId);
        response.put("count", count);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/search")
    public ResponseEntity<List<AttachmentDTO>> searchAttachments(@RequestParam String filename) {
        List<AttachmentDTO> attachments = attachmentService.searchAttachmentsByFilename(filename);
        return ResponseEntity.ok(attachments);
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<AttachmentDTO>> getAttachmentsByUserId(@PathVariable Long userId) {
        List<AttachmentDTO> attachments = attachmentService.getAttachmentsByUserId(userId);
        return ResponseEntity.ok(attachments);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updateAttachment(
            @PathVariable Long id, 
            @Valid @RequestBody AttachmentDTO attachmentDTO) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            Optional<AttachmentDTO> updatedAttachment = attachmentService.updateAttachment(id, attachmentDTO);
            if (updatedAttachment.isPresent()) {
                response.put("success", true);
                response.put("message", "Đã cập nhật attachment thành công");
                response.put("data", updatedAttachment.get());
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "Attachment không tồn tại");
                return ResponseEntity.notFound().build();
            }
        } catch (RuntimeException e) {
            response.put("success", false);
            response.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
        }
    }
} 