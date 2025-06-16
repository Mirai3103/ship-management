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
    

    Page<ChecklistTemplate> findByShipId(Long shipId, Pageable pageable);
    List<ChecklistTemplate> findByShipId(Long shipId);
    List<ChecklistTemplate> findByIdIsIn(List<Long> ids);

    Optional<ChecklistTemplate> findFirstByShipIdAndSection(Long shipId, String section);
    

    Page<ChecklistTemplate> findByCompanyId(Long companyId, Pageable pageable);
    

    Page<ChecklistTemplate> findByReviewPlanId(Long reviewPlanId, Pageable pageable);
    

    Page<ChecklistTemplate> findByShipIdAndCompanyId(Long shipId, Long companyId, Pageable pageable);
    

    Page<ChecklistTemplate> findBySectionContainingIgnoreCase(String section, Pageable pageable);
    

    List<ChecklistTemplate> findByShipIdOrderByOrderNoAsc(Long shipId);
    

    long countByShipId(Long shipId);
    

    boolean existsBySectionAndShipId(String section, Long shipId);
    

    @Query("SELECT ct FROM ChecklistTemplate ct LEFT JOIN FETCH ct.checklistItems WHERE ct.id = :id")
    Optional<ChecklistTemplate> findByIdWithItems(@Param("id") Long id);
} 