package com.fieldnotes.repository;

import com.fieldnotes.model.Site;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;
import java.util.Optional;

@Repository
public interface SiteRepository extends JpaRepository<Site, String> {
    List<Site> findByCustomerUserIdAndDeletedFalseOrderByNameAsc(Long userId);
    List<Site> findByCustomerIdAndDeletedFalseOrderByNameAsc(String customerId);
    Optional<Site> findByIdAndCustomerUserId(String id, Long userId);
    List<Site> findByCustomerUserIdAndUpdatedAtAfter(Long userId, Instant updatedAt);
    List<Site> findByCustomerUserId(Long userId);
}

