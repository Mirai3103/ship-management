package com.ship.management.repository;

import com.ship.management.entity.ChecklistTemplate;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ChecklistTemplateRepository extends JpaRepository<ChecklistTemplate, Long> {
    
    // Find by ship
    Page<ChecklistTemplate> findByShipId(Long shipId, Pageable pageable);
    List<ChecklistTemplate> findByIdIsIn(List<Long> ids);

    Optional<ChecklistTemplate> findFirstByShipIdAndSection(Long shipId, String section);
    
    // Find by company
    Page<ChecklistTemplate> findByCompanyId(Long companyId, Pageable pageable);
    
    // Find by review plan
    Page<ChecklistTemplate> findByReviewPlanId(Long reviewPlanId, Pageable pageable);
    
    // Find by ship and company
    Page<ChecklistTemplate> findByShipIdAndCompanyId(Long shipId, Long companyId, Pageable pageable);
    
    // Find by section name containing (for search)
    Page<ChecklistTemplate> findBySectionContainingIgnoreCase(String section, Pageable pageable);
    
    // Find by ship ordered by orderNo
    List<ChecklistTemplate> findByShipIdOrderByOrderNoAsc(Long shipId);
    
    // Count by ship
    long countByShipId(Long shipId);
    
    // Check if section exists for a ship
    boolean existsBySectionAndShipId(String section, Long shipId);
    
    // Custom query to find templates with item count
    @Query("SELECT ct FROM ChecklistTemplate ct LEFT JOIN FETCH ct.checklistItems WHERE ct.id = :id")
    Optional<ChecklistTemplate> findByIdWithItems(@Param("id") Long id);
} 