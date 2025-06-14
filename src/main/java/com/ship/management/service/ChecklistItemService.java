package com.ship.management.service;

import org.modelmapper.ModelMapper;
import org.springframework.stereotype.Service;

import com.ship.management.dto.ChecklistItemDTO;
import com.ship.management.dto.UpdateItemDTO;
import com.ship.management.entity.ChecklistItem;
import com.ship.management.repository.ChecklistItemRepository;
import com.ship.management.repository.ChecklistTemplateRepository;
import com.ship.management.repository.UserRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ChecklistItemService {
    private final ChecklistItemRepository checklistItemRepository;
    private final ChecklistTemplateRepository checklistTemplateRepository;
    private final UserRepository userRepository;
    private final ModelMapper modelMapper;

    public ChecklistItemDTO createChecklistItem(ChecklistItemDTO checklistItemDTO) {
        var checklistItem = new ChecklistItem();
        checklistItem.setContent(checklistItemDTO.getContent());
        checklistItem.setGuide(checklistItemDTO.getGuide());
        checklistItem.setOrderNo(checklistItemDTO.getOrderNo());
        checklistItem.setChecklistTemplate(checklistTemplateRepository.findById(checklistItemDTO.getChecklistTemplateId()).orElseThrow(() -> new RuntimeException("Checklist template not found")));
        checklistItem.setAssignedTo(userRepository.findById(checklistItemDTO.getAssignedToId()).orElseThrow(() -> new RuntimeException("User not found")));
        checklistItem.setComAssignedTo(userRepository.findById(checklistItemDTO.getComAssignedToId()).orElseThrow(() -> new RuntimeException("User not found")));
        checklistItem = checklistItemRepository.save(checklistItem);
        return modelMapper.map(checklistItem, ChecklistItemDTO.class);
    }

    public void deleteChecklistItem(Long id) {
        checklistItemRepository.deleteById(id);
    }

    public ChecklistItemDTO updateChecklistItem(UpdateItemDTO updateItemDTO) {
        ChecklistItem checklistItem = checklistItemRepository.findById(updateItemDTO.getId()).orElseThrow(() -> new RuntimeException("Checklist item not found"));
        checklistItem.setContent(updateItemDTO.getContent());
        checklistItem.setGuide(updateItemDTO.getGuide());
        checklistItem.setOrderNo(updateItemDTO.getOrderNo());
        checklistItem = checklistItemRepository.save(checklistItem);
        return modelMapper.map(checklistItem, ChecklistItemDTO.class);
    }
  
}
