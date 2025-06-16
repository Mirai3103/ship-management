package com.ship.management.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.ship.management.entity.ChecklistItem;

import java.util.Collection;
import java.util.List;

public interface ChecklistItemRepository extends JpaRepository<ChecklistItem, Long> {

    List<ChecklistItem> findByIdIsIn(Collection<Long> ids);
}
