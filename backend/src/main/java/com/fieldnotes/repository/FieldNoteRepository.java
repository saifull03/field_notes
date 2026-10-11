package com.fieldnotes.repository;

import com.fieldnotes.model.FieldNote;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;
import java.util.Optional;

@Repository
public interface FieldNoteRepository extends JpaRepository<FieldNote, String> {

    @Query("SELECT n FROM FieldNote n " +
           "JOIN FETCH n.site s " +
           "JOIN FETCH s.customer c " +
           "WHERE c.user.id = :userId AND n.deleted = false " +
           "ORDER BY n.dateTime DESC")
    List<FieldNote> findAllByUserIdWithDetails(@Param("userId") Long userId);

    @Query("SELECT n FROM FieldNote n " +
           "JOIN FETCH n.site s " +
           "JOIN FETCH s.customer c " +
           "WHERE n.id = :id AND c.user.id = :userId")
    Optional<FieldNote> findByIdAndUserIdWithDetails(@Param("id") String id, @Param("userId") Long userId);

    @Query("SELECT n FROM FieldNote n " +
           "JOIN FETCH n.site s " +
           "JOIN FETCH s.customer c " +
           "WHERE c.user.id = :userId " +
           "AND n.deleted = false " +
           "AND (:status IS NULL OR :status = '' OR n.status = :status) " +
           "AND (:siteId IS NULL OR :siteId = '' OR s.id = :siteId) " +
           "AND (:customerId IS NULL OR :customerId = '' OR c.id = :customerId) " +
           "AND (:query IS NULL OR :query = '' OR (" +
           "     LOWER(n.title) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "     LOWER(n.description) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "     LOWER(s.name) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "     LOWER(c.name) LIKE LOWER(CONCAT('%', :query, '%'))" +
           ")) " +
           "ORDER BY n.dateTime DESC")
    List<FieldNote> searchNotes(@Param("userId") Long userId,
                                @Param("query") String query,
                                @Param("status") String status,
                                @Param("siteId") String siteId,
                                @Param("customerId") String customerId);

    @Query("SELECT n FROM FieldNote n " +
           "JOIN n.site s " +
           "JOIN s.customer c " +
           "WHERE c.user.id = :userId " +
           "AND n.updatedAt > :updatedAt")
    List<FieldNote> findByUserIdAndUpdatedAtAfter(@Param("userId") Long userId, @Param("updatedAt") Instant updatedAt);

    @Query("SELECT n FROM FieldNote n " +
           "JOIN n.site s " +
           "JOIN s.customer c " +
           "WHERE c.user.id = :userId")
    List<FieldNote> findAllByUserId(@Param("userId") Long userId);
}
