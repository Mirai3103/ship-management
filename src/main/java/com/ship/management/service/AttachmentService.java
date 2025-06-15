package com.ship.management.service;

import com.ship.management.dto.AttachmentDTO;
import com.ship.management.entity.Attachment;
import com.ship.management.entity.ChecklistItem;
import com.ship.management.entity.User;
import com.ship.management.repository.AttachmentRepository;
import com.ship.management.repository.ChecklistItemRepository;
import com.ship.management.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import net.coobird.thumbnailator.Thumbnails;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.net.MalformedURLException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@Slf4j
@Service
@RequiredArgsConstructor
public class AttachmentService {

    private final AttachmentRepository attachmentRepository;
    private final ChecklistItemRepository checklistItemRepository;
    private final UserRepository userRepository;
    private final ModelMapper modelMapper;

    @Value("${app.upload.dir:uploads}")
    private String uploadDir;

    @Value("${app.server.url:http://localhost:8080}")
    private String serverUrl;

    public Page<AttachmentDTO> getAllAttachments(Pageable pageable) {
        Page<Attachment> attachments = attachmentRepository.findAll(pageable);
        return attachments.map(this::convertToDTO);
    }

    public Optional<AttachmentDTO> getAttachmentById(Long id) {
        return attachmentRepository.findById(id)
                .map(this::convertToDTO);
    }

    public List<AttachmentDTO> getAttachmentsByChecklistItemId(Long checklistItemId) {
        return attachmentRepository.findByChecklistItemIdWithUser(checklistItemId)
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public Page<AttachmentDTO> getAttachmentsByChecklistItemId(Long checklistItemId, Pageable pageable) {
        Page<Attachment> attachments = attachmentRepository.findByChecklistItemId(checklistItemId, pageable);
        return attachments.map(this::convertToDTO);
    }

    public List<AttachmentDTO> getAttachmentsByUserId(Long userId) {
        return attachmentRepository.findByUploadedById(userId)
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public List<AttachmentDTO> searchAttachmentsByFilename(String filename) {
        return attachmentRepository.findByFilenameContainingIgnoreCase(filename)
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    public long countByChecklistItemId(Long checklistItemId) {
        return attachmentRepository.countByChecklistItemId(checklistItemId);
    }

    public AttachmentDTO uploadSingleFile(MultipartFile file, Long checklistItemId, Long uploadedById)
            throws IOException {
        if (file.isEmpty()) {
            throw new RuntimeException("File không được để trống");
        }

        ChecklistItem checklistItem = checklistItemRepository.findById(checklistItemId)
                .orElseThrow(() -> new RuntimeException("Checklist item không tồn tại"));

        User uploadedBy = userRepository.findById(uploadedById)
                .orElseThrow(() -> new RuntimeException("Người dùng không tồn tại"));

        Path uploadPath = Paths.get(uploadDir);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        String originalFilename = StringUtils.cleanPath(Objects.requireNonNull(file.getOriginalFilename()));
        String fileExtension = getFileExtension(originalFilename);
        String uniqueFilename = UUID.randomUUID() + "_" + System.currentTimeMillis() + fileExtension;

        Path targetLocation = uploadPath.resolve(uniqueFilename);
        Files.copy(file.getInputStream(), targetLocation, StandardCopyOption.REPLACE_EXISTING);

        Attachment attachment = new Attachment();
        attachment.setChecklistItem(checklistItem);
        attachment.setUploadedBy(uploadedBy);
        attachment.setFilename(originalFilename);
        attachment.setFileUrl(serverUrl + "/api/attachments/download/" + uniqueFilename);
        attachment.setUploadedAt(LocalDateTime.now());
        new Thread(() -> {
            if (isImageFile(originalFilename)) {
                compressImage(targetLocation.toString());
            } else if (isVideoFile(originalFilename)) {
                compressVideo(targetLocation.toString());
            }
        }).start();

        Attachment savedAttachment = attachmentRepository.save(attachment);
        return convertToDTO(savedAttachment);
    }

    public List<AttachmentDTO> uploadMultipleFiles(MultipartFile[] files, Long checklistItemId, Long uploadedById)
            throws IOException {
        if (files == null || files.length == 0) {
            throw new RuntimeException("Không có file nào được chọn");
        }

        return Stream.of(files)
                .map(file -> {
                    try {
                        return uploadSingleFile(file, checklistItemId, uploadedById);
                    } catch (IOException e) {
                        throw new RuntimeException(
                                "Lỗi khi tải file: " + file.getOriginalFilename() + " - " + e.getMessage());
                    }
                })
                .collect(Collectors.toList());
    }

    public AttachmentDTO createAttachment(AttachmentDTO attachmentDTO) {
        ChecklistItem checklistItem = checklistItemRepository.findById(attachmentDTO.getChecklistItemId())
                .orElseThrow(() -> new RuntimeException("Checklist item không tồn tại"));

        User uploadedBy = userRepository.findById(attachmentDTO.getUploadedById())
                .orElseThrow(() -> new RuntimeException("Người dùng không tồn tại"));

        Attachment attachment = new Attachment();
        attachment.setChecklistItem(checklistItem);
        attachment.setUploadedBy(uploadedBy);
        attachment.setFilename(attachmentDTO.getFilename());
        attachment.setFileUrl(attachmentDTO.getFileUrl());
        attachment.setUploadedAt(LocalDateTime.now());

        Attachment savedAttachment = attachmentRepository.save(attachment);
        return convertToDTO(savedAttachment);
    }

    public Optional<AttachmentDTO> updateAttachment(Long id, AttachmentDTO attachmentDTO) {
        return attachmentRepository.findById(id)
                .map(existingAttachment -> {
                    // Update only allowed fields (not checklistItem, uploadedBy, uploadedAt)
                    existingAttachment.setFilename(attachmentDTO.getFilename());
                    // Don't update fileUrl as it should be managed by file upload
                    Attachment updatedAttachment = attachmentRepository.save(existingAttachment);
                    return convertToDTO(updatedAttachment);
                });
    }

    public boolean deleteAttachment(Long id) {
        Optional<Attachment> attachmentOpt = attachmentRepository.findById(id);
        if (attachmentOpt.isPresent()) {
            attachmentRepository.deleteById(id);
            return true;
        }
        return false;
    }

    public Resource downloadFile(String filename) throws MalformedURLException {
        Path filePath = Paths.get(uploadDir).resolve(filename).normalize();
        Resource resource = new UrlResource(filePath.toUri());

        if (resource.exists() && resource.isReadable()) {
            return resource;
        } else {
            throw new RuntimeException("File không tồn tại: " + filename);
        }
    }

    public String getOriginalFilename(String filename) {
        // Extract original filename from unique filename
        // Format: UUID_timestamp_originalname.ext
        if (filename.contains("_")) {
            String[] parts = filename.split("_", 3);
            if (parts.length >= 3) {
                return parts[2];
            }
        }
        return filename;
    }

    private String getFileExtension(String filename) {
        if (filename == null || filename.isEmpty()) {
            return "";
        }
        int lastDotIndex = filename.lastIndexOf(".");
        return (lastDotIndex != -1) ? filename.substring(lastDotIndex) : "";
    }

    private AttachmentDTO convertToDTO(Attachment attachment) {
        AttachmentDTO dto = modelMapper.map(attachment, AttachmentDTO.class);

        if (attachment.getUploadedBy() != null) {
            dto.setUploadedById(attachment.getUploadedBy().getId());
            dto.setUploadedByName(attachment.getUploadedBy().getFullName());
        }

        if (attachment.getChecklistItem() != null) {
            dto.setChecklistItemId(attachment.getChecklistItem().getId());
        }

        return dto;
    }

    private Attachment convertToEntity(AttachmentDTO attachmentDTO) {
        return modelMapper.map(attachmentDTO, Attachment.class);
    }

    public void compressImage(String path) {
        if (!isImageFile(path)) {
            System.out.println("Đây không phải là file ảnh hợp lệ.");
            return;
        }

        File originalFile = new File(path);
        long originalSize = originalFile.length();
        long maxSize = 500 * 1024;

        if (!originalFile.exists() ) {
            System.out.println("Ảnh  không tồn tại.");
            return;
        }
        log.info("Bắt đầu nén ảnh: {} ({}KB)", originalFile.getName(), originalSize / 1024);

        File tempFile = new File("temp_" + originalFile.getName());

        try {
            BufferedImage image = ImageIO.read(originalFile);

            double scale = 1.0;
            float quality = 1.0f;
            var imageWidth = image.getWidth();
            if (imageWidth > 1920) {
                scale = 1024.0 / imageWidth;
            }

            if (originalSize > 300 * 1024) {
                // >300KB: giảm chất lượng còn 50%, giữ nguyên kích thước
                quality = 0.5f;
            } else {
                // ≤300KB: giảm kích thước còn 80%, giữ nguyên chất lượng
                scale = 0.8;
            }


            Thumbnails.of(image)
                    .scale(scale)
                    .outputQuality(quality)
                    .toFile(tempFile);

            long newSize = tempFile.length();
            log.info("Ảnh đã được nén: {} ({}KB)", tempFile.getName(), newSize / 1024);
            Files.move(tempFile.toPath(), originalFile.toPath(), StandardCopyOption.REPLACE_EXISTING);

        } catch (IOException e) {
            log.error("Lỗi khi nén ảnh: {}", e.getMessage());
        } finally {
            if (tempFile.exists()) {
                tempFile.delete();
            }
        }
    }

    public boolean isFFmpegInstalled() {
        try {
            Process process = new ProcessBuilder("ffmpeg", "-version").start();
            int exitCode = process.waitFor();
            return exitCode == 0;
        } catch (IOException | InterruptedException e) {
            return false;
        }
    }

    private boolean isVideoFile(String path) {
        String[] videoExtensions = {".mp4", ".avi", ".mkv", ".mov", ".flv", ".wmv"};
        String fileExtension = path.substring(path.lastIndexOf('.')).toLowerCase();
        for (String ext : videoExtensions) {
            if (fileExtension.equals(ext)) {
                return true;
            }
        }
        return false;
    }

    private boolean isImageFile(String path) {
        String[] imageExtensions = {".jpg", ".jpeg", ".png", ".gif", ".bmp", ".tiff"};
        String fileExtension = path.substring(path.lastIndexOf('.')).toLowerCase();
        for (String ext : imageExtensions) {
            if (fileExtension.equals(ext)) {
                return true;
            }
        }
        return false;
    }

    public void compressVideo(String path) {
        if (!isVideoFile(path)) {
            System.out.println("Đây không phải là file video hợp lệ.");
            return;
        }
        if (!isFFmpegInstalled()) {
            return;
        }
        try {

            File originalFile = new File(path);
            var originalSize = originalFile.length();
            log.info("Bắt đầu nén video: {} ({}KB)", originalFile.getName(), originalSize / 1024);
            var output = new File("compressed_" + originalFile.getName());
            String[] command = {
                    "ffmpeg",
                    "-y",
                    "-i", originalFile.getAbsolutePath(),
                    "-vcodec", "libx264",
                    "-preset", "ultrafast",
                    "-crf", "30",                // nén mạnh hơn (nhiều mất chất lượng)
                    "-acodec", "copy",           // giữ nguyên âm thanh
                    output.getAbsolutePath()
            };
            ProcessBuilder builder = new ProcessBuilder(command);
            builder.redirectErrorStream(true);
            Process process = builder.start();
            new Thread(() -> {
                try (var reader = new java.io.BufferedReader(
                        new java.io.InputStreamReader(process.getInputStream()))) {
                    String line;
                    while ((line = reader.readLine()) != null) {
                        System.out.println(line);
                    }
                } catch (IOException ignored) {
                }
            }).start();

            int exitCode = process.waitFor();
            if (exitCode == 0) {
                log.info("✅ Video đã được nén thành công: {} ({}KB)", output.getPath(), output.length() / 1024);
                Files.move(output.toPath(), originalFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
            } else {
                log.error("❌ Lỗi khi nén video. Exit code: {}", exitCode);
            }

        } catch (IOException |
                 InterruptedException e) {
            e.printStackTrace();
        }
    }
}
