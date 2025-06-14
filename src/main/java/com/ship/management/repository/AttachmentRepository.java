package com.ship.management.repository;

import com.ship.management.entity.Attachment;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AttachmentRepository extends JpaRepository<Attachment, Long> {
    
    // Find attachments by checklist item
    List<Attachment> findByChecklistItemId(Long checklistItemId);
    
    // Find attachments by checklist item with pagination
    Page<Attachment> findByChecklistItemId(Long checklistItemId, Pageable pageable);
    
    // Find attachments by uploaded user
    List<Attachment> findByUploadedById(Long uploadedById);
    
    // Find attachments by filename containing (for search)
    List<Attachment> findByFilenameContainingIgnoreCase(String filename);
    
    // Count attachments by checklist item
    long countByChecklistItemId(Long checklistItemId);
    
    // Find attachments by checklist item and uploaded by user
    List<Attachment> findByChecklistItemIdAndUploadedById(Long checklistItemId, Long uploadedById);
    
    // Custom query to get attachments with user details
    @Query("SELECT a FROM Attachment a LEFT JOIN FETCH a.uploadedBy WHERE a.checklistItem.id = :checklistItemId ORDER BY a.uploadedAt DESC")
    List<Attachment> findByChecklistItemIdWithUser(@Param("checklistItemId") Long checklistItemId);
    
    // Find recent attachments by user
    @Query("SELECT a FROM Attachment a WHERE a.uploadedBy.id = :userId ORDER BY a.uploadedAt DESC")
    List<Attachment> findRecentByUploadedById(@Param("userId") Long userId, Pageable pageable);
} 