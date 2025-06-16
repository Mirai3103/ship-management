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
    

    List<Attachment> findByChecklistItemId(Long checklistItemId);
    

    Page<Attachment> findByChecklistItemId(Long checklistItemId, Pageable pageable);
    

    List<Attachment> findByUploadedById(Long uploadedById);
    

    List<Attachment> findByFilenameContainingIgnoreCase(String filename);
    

    long countByChecklistItemId(Long checklistItemId);
    

    List<Attachment> findByChecklistItemIdAndUploadedById(Long checklistItemId, Long uploadedById);
    

    @Query("SELECT a FROM Attachment a LEFT JOIN FETCH a.uploadedBy WHERE a.checklistItem.id = :checklistItemId ORDER BY a.uploadedAt DESC")
    List<Attachment> findByChecklistItemIdWithUser(@Param("checklistItemId") Long checklistItemId);
    

    @Query("SELECT a FROM Attachment a WHERE a.uploadedBy.id = :userId ORDER BY a.uploadedAt DESC")
    List<Attachment> findRecentByUploadedById(@Param("userId") Long userId, Pageable pageable);
} 