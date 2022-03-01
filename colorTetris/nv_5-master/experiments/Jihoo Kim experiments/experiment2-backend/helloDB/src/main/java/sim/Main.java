package sim;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import sim.model.Book;
import sim.repository.BookRepository;

@SpringBootApplication
public class Main implements CommandLineRunner
{
    @Autowired
    private BookRepository bookRepository;

    public static void main(String[] args)
    {
        SpringApplication.run(Main.class, args);
    }
    @Override
    public void run(String... args) throws Exception
    {
        Book book1 = new Book("Choco");
        Book book2 = new Book("Milk");

        bookRepository.save(book1);
        bookRepository.save(book2);
    }

}
