#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"


/* Requirements
 *  find all the files in a directory tree with a specific name.
 *  $ echo "hello" > somefile.txt
 *  $ echo "world" > else.txt
 *  $ find . .txt
 *  somefile.txt
 *  else.txt
 */


void print_substrings(char *fname, char *term)
{
    /* strategy is to use strchr to find if each character of term
     * is found on fname. If it does, it checks if they're in sequential
     * order */ 
    char *pfname, *pterm, *ptermi, *pfnamei;
    int j=0;
    int vseek=1; // valid seek control flag

    pfname = fname; pterm = term;
    for(int i=0; i<strlen(fname); i++)
    {
        /* in this loop we try to find first occurrance */
        //printf("%d %d %d\n", *p1, *p2, *p1 == *p2);
        if (*pfname == *pterm) {
            /* meaning that the beginning of both strs have matched */
            /* we set an pointer that iterates in fname */
            pfnamei = pfname;
            ptermi = pterm;
            for(j=0; j<strlen(term) && vseek == 1; j++) {
                /* now we must find consecutives matches of term (p2) inside 
                 * fname (p1) */
                if (*pfnamei && *ptermi && *pfnamei == *ptermi) 
                {
                    /* since we're adding p2 which points to term, strlen behaves
                     * unexpectedly. Hence we need to check if p2 and p3 are
                     * valid */
                    pfnamei++;
                    ptermi++;
                }
                else
                {
                    /* if anything doesn't match, its not a substr */
                    vseek = 0;
                    //break;
                }
            }
            if(j == strlen(term) && vseek == 1) {
                printf("%s\n", fname);
            }
        }
        ++pfname;
        vseek = 1;
    }

}

void
find(char *dirpath, char *term)
{
  // iterate on every file in dirpath
  // and compare it to fname
  // if its a dir we can skip it
  int fd;
  struct stat st;
  struct dirent de;
  char buf[512], *p;

  if((fd = open(dirpath, 0)) < 0)
    /* we're both opening a fd and also checking for errors */
  {
    fprintf(2, "find: directory %s does not exist\n", dirpath);
    return;
  }

  if(fstat(fd, &st) < 0)
  {
    /* we're both getting stat for fd and checking for errors */
    fprintf(2, "find: cannot get status for directory %s\n", dirpath);
    return;
  }

  switch(st.type)
  {
  case T_FILE:
      fprintf(2, "find: %s is a file not a directory.", dirpath);
      break;
  case T_DIR:
      strcpy(buf, dirpath);  /* copy dirpath content into buf */
      p = buf + strlen(buf); /* points to the end of dirpath inside buf */ 
      *p++ = '/';  /* now it adds a / after dirpath */ 
      /* p is pointing to the end of dir/ */
      while(read(fd, &de, sizeof(de)) == sizeof(de))
      {
          if (de.inum == 0) continue;
          /* paste next dirname */
          memmove(p, de.name, DIRSIZ);
          p[DIRSIZ] = 0;
        
          if(stat(buf, &st) < 0)
          {
              fprintf(2, "find: cannot get status for file %s", de.name);
              return;
          }
          if(st.type == T_DIR)
          {
              if (strcmp(de.name, ".") == 0 || strcmp(de.name, "..") == 0)
                  continue;

              find(buf, term);
          }
          else if(st.type == T_FILE)
          {
              if (!strcmp(de.name, term)) printf("%s\n", buf);
              
              /* support for substrings: uncomment next line */
              //print_substrings(buf, term);
          }
      }
      break;
  }
  close(fd);
}

int
main(int argc, char *argv[])
{
    if(argc != 3)
    {
        fprintf(2, "USAGE: find <directory> <filename>");
        exit(1);
    } 
    find(argv[1], argv[2]);
    exit(0);
}
