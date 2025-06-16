package com.ship.management.api;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.ship.management.dto.ChecklistItemDTO;
import com.ship.management.dto.CopyCheckListDTO;
import com.ship.management.dto.ReviewDTO;
import com.ship.management.dto.UpdateItemDTO;
import com.ship.management.entity.Role.RootRole;
import com.ship.management.service.ChecklistItemService;
import com.ship.management.service.UserService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/checklist-items")
@RequiredArgsConstructor
public class ChecklistItemController {
    private final ChecklistItemService checklistItemService;
    private final UserService userService;

    @PostMapping
    public ChecklistItemDTO createChecklistItem(@RequestBody ChecklistItemDTO checklistItemDTO) {
        return checklistItemService.createChecklistItem(checklistItemDTO);
    }

    @DeleteMapping("/{id}")
    public void deleteChecklistItem(@PathVariable Long id) {
        checklistItemService.deleteChecklistItem(id);
    }

    @PatchMapping("/{id}")
    public ChecklistItemDTO updateChecklistItem(@PathVariable Long id, @RequestBody UpdateItemDTO updateItemDTO) {
        updateItemDTO.setId(id);
        return checklistItemService.updateChecklistItem(updateItemDTO);
    }

    @PatchMapping("/{id}/review")
    public ChecklistItemDTO reviewChecklistItem(@PathVariable Long id, @RequestBody ReviewDTO reviewItemDTO) {
        reviewItemDTO.setChecklistItemId(id);
        var currentRootRole = userService.getCurrentUserRootRole();
        if(currentRootRole == RootRole.SHIP) {
            return checklistItemService.reviewFromShip(reviewItemDTO);
        } else if(currentRootRole == RootRole.COMPANY) {
            return checklistItemService.reviewFromCompany(reviewItemDTO);
        }
        throw new RuntimeException("User not found");
    }

    @PostMapping("/copy")
    public void copyChecklistToShip(@RequestBody CopyCheckListDTO copyCheckListDTO) {
        checklistItemService.copyCheckListToShip(copyCheckListDTO);
    }
}
