# Changelog

Todas as mudanças relevantes deste projeto serão documentadas aqui.

O formato segue a ideia do [Keep a Changelog](https://keepachangelog.com/), com versões em ordem cronológica reversa.

## [r6.1] - 2026-11-17

### Fixed
- Alterado o shebang do executável para `#!/usr/bin/env bash`, evitando assumir que Bash existe em `/bin/bash` em ambientes como Termux.
- Corrigido o tratamento de argumentos ausentes e comandos desconhecidos.
- Corrigida a geração de snapshots para incluir dotfiles no modo não-recursivo.
- Corrigida a exclusão de arquivos internos e bancos Git, Pijul, Mercurial e Subversion em caminhos aninhados.
- Links simbólicos agora são registrados com metadados `stat` e destino `readlink`, sem seguir o destino nem calcular hash do conteúdo.
- Corrigida a saída de metadados, removendo a duplicação de sinais de porcentagem e evitando armazenar a saída inteira em uma variável.
- Tornado `b3sum` o mecanismo prioritário e único de digest BLAKE3-256, lendo arquivos via stdin em streaming.
- Desativados os métodos Python de CIDv0/CIDv1 enquanto a implementação nativa Bash de CIDv1 é preparada.
- Removida do fluxo de hash a chamada `iroh blobs add`, que podia persistir o conteúdo no armazenamento local do Iroh.
- Tornados os diagnósticos de armazenamento tolerantes a falhas de `df` e `lsblk`.
- Redigidas credenciais embutidas em URLs de remotes Git antes de incluí-las em snapshots.

### Safety
- O comando `save` mantém um arquivo `folderstamp.incomplete` em um workspace próprio, acompanhado de lista NUL-delimited e checkpoint.
- O progresso só avança depois que os dados do snapshot e o checkpoint são sincronizados; falhas deixam o arquivo incompleto disponível para retomada.
- Adicionado `folderstamp resume PATH`, que retoma a partir do último checkpoint durável e não publica um snapshot final até concluir.
- O instalador preserva a instalação anterior em um arquivo de backup antes de publicar uma nova versão.
- Iroh e Kubo permanecem ferramentas opcionais de validação, mas não são chamados pelo fluxo de snapshot nem recebem conteúdo para armazenamento.

### Documentation
- README atualizado com links simbólicos, recuperação de snapshots interrompidos, instalação automática de `b3sum` via `apt`/`pkg`, digest BLAKE3 em streaming e a pendência do encoder CIDv1 nativo em Bash.
- To-do atualizado com testes de nomes complexos, gitignore, CIDv0 single-block, verificação criptográfica de downloads e suporte futuro a cartão SD no Termux (PR 2/2).


### Fixed
- Alterado o shebang do executável para `#!/usr/bin/env bash`, evitando assumir que Bash existe em `/bin/bash` em ambientes como Termux.
- Corrigido o tratamento de argumentos ausentes e comandos desconhecidos.
- Corrigida a geração de snapshots para incluir dotfiles no modo não-recursivo.
- Corrigida a exclusão de arquivos internos e bancos Git, Pijul, Mercurial e Subversion em caminhos aninhados.
- Corrigido o tratamento de links simbólicos: eles não são seguidos nem migrados como snapshots.
- Corrigida a saída de metadados, removendo a duplicação de sinais de porcentagem e evitando armazenar a saída inteira em uma variável.
- Tornado o fallback CIDv0 single-block e o fallback CIDv1/BLAKE3 incrementais, evitando carregar arquivos inteiros na memória.
- Tornados os diagnósticos de armazenamento tolerantes a falhas de `df` e `lsblk`, comuns em ambientes minimalistas.
- Redigidas credenciais embutidas em URLs de remotes Git antes de incluí-las em snapshots.

### Safety
- O comando `save` agora gera o snapshot em arquivo temporário exclusivo e só publica o resultado após a geração terminar com sucesso.
- A publicação usa renomeação no mesmo diretório e não substitui snapshots existentes.
- A migração do stamp legado recusa symlinks, arquivos especiais e diretórios de metadados que sejam symlinks.
- O instalador preserva a instalação anterior em um arquivo de backup antes de publicar uma nova versão.
- Instalações de ferramentas baixadas de Releases também passam a preservar o executável anterior e usar publicação por arquivo temporário.

### Documentation
- Adicionado README com instalação, uso, limitações e notas de Termux.
- Atualizada a lista de tarefas para refletir as correções desta revisão.

## [r6] - 2026-08-15

### Added
- Adicionado relatório de dependências no `folderstamp`, detectando `stat`, `git`/Gitoxide, `pijul`, Iroh, Python + `blake3` e `ipfs`.
- Renomeado o rótulo de saída de `IPFS hash:` para `CID hash:` para cobrir IPFS, Iroh e outros ecossistemas que usam CID sem acoplar marca.
- Implementado fallback Python + `blake3` que gera CIDv1 raw/BLAKE3; o estudo CIDv0 single-block UnixFS/DAG-PB segue disponível como último fallback Python.
- Alterado `save` para armazenar novos stamps em `.meta/folderstamp/` em vez de criar `.folderstamp` na raiz.
- Adicionada migração automática de `.folderstamp` legado para `.meta/folderstamp/.folderstamp.1`, criando o próximo número disponível para novos stamps.
- Adicionado instalador interativo para Kubo/IPFS e Gitoxide via GitHub Releases quando o usuário confirma no prompt.
- Adicionado Gitoxide como opção padrão sugerida mesmo quando Git clássico já existe, sem exigir passos manuais em sessão interativa.
- Adicionado suporte de portabilidade para BSD, macOS e Zircon/Fuchsia.
- Criado `SKILL.md` com práticas de Bash portátil, diagnósticos, dependências e documentação.
- Adicionado suporte a repositórios Pijul ao lado do Git.
- Adicionada instalação interativa do `stat` normal pelo package manager da plataforma; uutils/coreutils via GitHub Releases ficou como alternativa compatível em Rust.
- Iroh passou a produzir CIDv1/raw/BLAKE3; IPFS/Kubo continua como fallback de compatibilidade.
- Adicionada rotação automática no armazenamento de stamps e suporte inicial a `.folderstampignore`.
- Adicionada flag `--help`/`-h`.
- Adicionado suporte explícito à detecção de plataforma para Termux, Cygwin e RedoxOS.
- Adicionado fallback para detalhes de armazenamento: usa `lsblk` quando disponível e recorre a `df -hP` quando possível.
- Criado `to-do.md` organizado a partir do antigo `Tasks.txt`.

### Changed
- Renomeado `Tasks.txt` para `to-do.md`.
- Mantida a versão interna do `folderstamp` em `r6`.
- Centralizada a lógica de carimbo de arquivos na função `stamp_path`.
- Centralizada a leitura de dados Git na função `print_git_details`.
- O instalador deixou de depender obrigatoriamente de `sudo`; agora usa caminhos graváveis pelo usuário primeiro.
- `folderstamp` e `install.sh` passaram a ser instaláveis/executáveis diretamente.

### Fixed
- Evitada falha em ambientes sem `lsblk`.
- Evitada falha ao exibir informações Git quando o repositório não possui remote configurado.
- Evitada dependência rígida de `/usr/bin`, que não é o destino correto em Termux, Cygwin ou RedoxOS.

## [r5] - Antes de 2026-08-15

### Existing
- Exibição do diretório atual.
- Exibição de informações de armazenamento via `lsblk` em Linux.
- Exibição da branch Git atual e primeiro remote quando `.git` existe.
- Suporte aos comandos `display` e `save`.
- Suporte ao modo recursivo com `--recursive` ou `-r`.
- Geração de hash IPFS usando `ipfs add -q --only-hash`.
