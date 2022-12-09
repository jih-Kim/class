package Repository;

import org.springframework.data.jpa.repository.JpaRepository;
import Entity.Current;


public interface CurrentRepository extends JpaRepository<Current, Long> {
    
}
