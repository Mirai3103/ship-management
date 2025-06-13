package com.ship.management.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.ship.management.entity.ChecklistItem;

public interface ChecklistItemRepository extends JpaRepository<ChecklistItem, Long> {
    
}
